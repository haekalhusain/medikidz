const functions = require("firebase-functions");
const { db, admin } = require("./db");
const {
  extractDateOnly,
  dateOnlyToUtcDate,
  toIsoDateString,
  dayStartIsoString,
  dayEndIsoString,
  addDaysUtc,
  todayUtc,
} = require("./dateUtils");
const {
  ACTIVE_NOTIF_OFFSETS,
  STATUS_TIDAK_PERLU_NOTIF,
  OFFSET_LABEL,
  FIRESTORE_IN_CHUNK_SIZE,
  BATCH_WRITE_CHUNK_SIZE,
} = require("./config");

const MASTER_CACHE_TTL_MS = 5 * 60 * 1000;
let masterCache = { data: null, fetchedAt: 0 };

async function getJadwalMaster() {
  const now = Date.now();
  if (masterCache.data && now - masterCache.fetchedAt < MASTER_CACHE_TTL_MS) {
    return masterCache.data;
  }
  const snap = await db.collection("tb_jadwalMaster").get();
  const data = snap.docs
    .map((d) => d.data())
    .filter((m) => m.nama_vaksin && m.usia_hari != null && m.urutan_dosis != null);
  masterCache = { data, fetchedAt: now };
  return data;
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function realisasiKey(idAnak, namaVaksin, urutanDosis) {
  return `${idAnak}|${(namaVaksin || "").toString().toLowerCase()}|${urutanDosis}`;
}

/**
 * Versi yang cocok dengan skema NYATA aplikasi:
 * - tb_jadwalImunisasi HANYA berisi dosis yang statusnya sudah pernah diubah
 *   (sudah imunisasi / dilewati / tidak bisa dikejar) atau dijadwal ulang manual.
 *   Dosis "belum imunisasi" default TIDAK punya dokumen sama sekali.
 * - Tanggal jatuh tempo "alami" = tanggal_lahir anak + usia_hari (dihitung di
 *   memori, PERSIS seperti JadwalScheduleService.computeJadwalForAnak di Flutter).
 * - Kalau ada tanggal_rencana_override, itu yang jadi tanggal jatuh tempo sebenarnya.
 *
 * Strategi baca hemat kuota:
 *   1. Baca tb_anak yang deleted_at == null saja (bukan seluruh koleksi).
 *   2. Baca tb_jadwalMaster (kecil, di-cache).
 *   3. Hitung kandidat "jatuh tempo alami" di memori (gratis, tidak nge-read Firestore).
 *   4. Query tb_jadwalImunisasi HANYA utk (a) dosis yang di-override jatuh ke jendela
 *      H-3..H-0, dan (b) dosis kandidat alami di atas -- supaya tau kalau ternyata
 *      sudah selesai/di-skip/di-reschedule. Ini query terarah, BUKAN scan koleksi utuh.
 */
async function runScheduleNotifications() {
  const today = todayUtc();
  const offsets = ACTIVE_NOTIF_OFFSETS;
  const targets = offsets.map((offset) => ({ offset, dateString: toIsoDateString(addDaysUtc(today, offset)) }));
  const targetDateStrings = new Set(targets.map((t) => t.dateString));
  const offsetByDateString = new Map(targets.map((t) => [t.dateString, t.offset]));

  const minOffset = Math.min(...offsets);
  const maxOffset = Math.max(...offsets);
  const windowStart = addDaysUtc(today, minOffset);
  const windowEnd = addDaysUtc(today, maxOffset);

  // --- 1 & 2: data dasar, bukan full scan tb_jadwalImunisasi ---
  const [anakSnap, masterList] = await Promise.all([
    db.collection("tb_anak").where("deleted_at", "==", null).get(),
    getJadwalMaster(),
  ]);

  // --- 3: kandidat "jatuh tempo alami" (hitung di memori, tanpa read Firestore) ---
  const naturalCandidates = []; // { idAnak, idUser, namaAnak, namaVaksin, urutanDosis, dateString, offset }
  anakSnap.docs.forEach((doc) => {
    const anak = doc.data();
    const lahir = extractDateOnly(anak.tanggal_lahir);
    if (!lahir || !anak.id_user) return;
    const lahirDate = dateOnlyToUtcDate(lahir);

    masterList.forEach((master) => {
      const due = addDaysUtc(lahirDate, master.usia_hari);
      const dueString = toIsoDateString(due);
      if (!targetDateStrings.has(dueString)) return;
      naturalCandidates.push({
        idAnak: doc.id,
        idUser: anak.id_user,
        namaAnak: anak.nama_anak,
        namaVaksin: master.nama_vaksin,
        urutanDosis: master.urutan_dosis,
        dateString: dueString,
        offset: offsetByDateString.get(dueString),
      });
    });
  });

  // --- 4a: cek status realisasi utk kandidat alami (query terarah per anak, di-chunk) ---
  const candidateAnakIds = [...new Set(naturalCandidates.map((c) => c.idAnak))];
  const realisasiMap = new Map(); // key -> { status, tanggal_rencana_override }

  if (candidateAnakIds.length > 0) {
    const chunks = chunk(candidateAnakIds, FIRESTORE_IN_CHUNK_SIZE);
    const results = await Promise.all(
      chunks.map((ids) => db.collection("tb_jadwalImunisasi").where("id_anak", "in", ids).get())
    );
    results.forEach((snap) => {
      snap.docs.forEach((doc) => {
        const r = doc.data();
        realisasiMap.set(realisasiKey(r.id_anak, r.nama_vaksin, r.urutan_dosis), {
          status: r.status,
          override: r.tanggal_rencana_override || null,
        });
      });
    });
  }

  // --- 4b: dosis yang di-override JATUH ke jendela H-3..H-0 (query bounded, bukan scan) ---
  const overrideSnap = await db
    .collection("tb_jadwalImunisasi")
    .where("tanggal_rencana_override", ">=", dayStartIsoString(windowStart))
    .where("tanggal_rencana_override", "<=", dayEndIsoString(windowEnd))
    .get();

  const overrideCandidates = [];
  overrideSnap.docs.forEach((doc) => {
    const r = doc.data();
    if (STATUS_TIDAK_PERLU_NOTIF.includes((r.status || "").toString().toLowerCase())) return;
    const overrideDateOnly = extractDateOnly(r.tanggal_rencana_override);
    if (!overrideDateOnly) return;
    const dateString = toIsoDateString(dateOnlyToUtcDate(overrideDateOnly));
    if (!targetDateStrings.has(dateString)) return;
    if (!r.id_anak || !r.nama_vaksin) return;
    overrideCandidates.push({
      idAnak: r.id_anak,
      idUser: r.id_user || null, // fallback di-resolve dari anakSnap kalau kosong
      namaAnak: r.nama_anak,
      namaVaksin: r.nama_vaksin,
      urutanDosis: r.urutan_dosis,
      dateString,
      offset: offsetByDateString.get(dateString),
    });
  });

  const anakById = new Map(anakSnap.docs.map((d) => [d.id, d.data()]));

  // --- Gabungkan: kandidat alami valid (belum di-override, belum selesai/skip) + kandidat override ---
  const finalTargets = [];
  const overriddenAnakVaksinKeys = new Set(
    overrideCandidates.map((c) => realisasiKey(c.idAnak, c.namaVaksin, c.urutanDosis))
  );

  naturalCandidates.forEach((c) => {
    const key = realisasiKey(c.idAnak, c.namaVaksin, c.urutanDosis);
    if (overriddenAnakVaksinKeys.has(key)) return; // sudah ditangani lewat jalur override
    const existing = realisasiMap.get(key);
    if (existing) {
      if (STATUS_TIDAK_PERLU_NOTIF.includes((existing.status || "").toString().toLowerCase())) return;
      if (existing.override) return; // ada override tapi jatuh di luar jendela -> bukan hari ini
    }
    finalTargets.push(c);
  });

  overrideCandidates.forEach((c) => {
    if (!c.idUser) {
      const anak = anakById.get(c.idAnak);
      c.idUser = anak ? anak.id_user : null;
    }
    if (!c.namaAnak) {
      const anak = anakById.get(c.idAnak);
      c.namaAnak = anak ? anak.nama_anak : null;
    }
    if (c.idUser && c.namaAnak) finalTargets.push(c);
  });

  if (finalTargets.length === 0) {
    console.log("[scheduleNotifications] tidak ada dosis jatuh tempo hari ini.");
    return { created: 0 };
  }

  // --- Dedup terhadap notifikasi yang sudah pernah dibuat (query terarah, bukan scan) ---
  const existingNotifSnap = await db
    .collection("tb_notifikasi")
    .where("kategori", "==", "jadwal")
    .where("jadwal_tanggal", "in", [...targetDateStrings])
    .get();

  const existingKeys = new Set();
  existingNotifSnap.docs.forEach((doc) => {
    const n = doc.data();
    existingKeys.add(
      `${n.uid || ""}|${(n.jadwal_nama_vaksin || "").toString().toLowerCase()}|${n.jadwal_urutan_dosis || ""}|${n.jadwal_tanggal || ""}`
    );
  });

  // --- Tulis notifikasi, di-chunk supaya tidak pernah kena limit 500 write/batch ---
  let batch = db.batch();
  let pendingInBatch = 0;
  const pendingCommits = [];
  let createdCount = 0;

  const flushIfNeeded = () => {
    if (pendingInBatch >= BATCH_WRITE_CHUNK_SIZE) {
      pendingCommits.push(batch.commit());
      batch = db.batch();
      pendingInBatch = 0;
    }
  };

  finalTargets.forEach((t) => {
    const dedupeKey = `${t.idUser}|${(t.namaVaksin || "").toString().toLowerCase()}|${t.urutanDosis}|${t.dateString}`;
    if (existingKeys.has(dedupeKey)) return;

    const label = OFFSET_LABEL[t.offset] ?? `H-${t.offset}`;
    const pesan =
      t.offset === 0
        ? `Hari ini jadwal imunisasi ${t.namaVaksin} untuk ${t.namaAnak}. Jangan lupa ya!`
        : `Imunisasi ${t.namaVaksin} untuk ${t.namaAnak} dijadwalkan tanggal ${t.dateString} (${label}). Persiapkan ya!`;

    const notifRef = db.collection("tb_notifikasi").doc();
    batch.set(notifRef, {
      uid: t.idUser,
      judul: `Pengingat Imunisasi ${t.namaVaksin} (${label})`,
      pesan,
      kategori: "jadwal",
      waktu: new Date().toISOString(),
      terbaca: false,
      jadwal_tanggal: t.dateString,
      jadwal_nama_vaksin: t.namaVaksin,
      jadwal_urutan_dosis: t.urutanDosis,
      jadwal_offset: label,
      source: "auto_cron",
    });
    existingKeys.add(dedupeKey);
    createdCount += 1;
    pendingInBatch += 1;
    flushIfNeeded();
  });

  if (pendingInBatch > 0) pendingCommits.push(batch.commit());
  await Promise.all(pendingCommits);

  console.log(
    `[scheduleNotifications] anakAktif=${anakSnap.size} kandidatAlami=${naturalCandidates.length} kandidatOverride=${overrideCandidates.length} dibuat=${createdCount}`
  );
  return { created: createdCount };
}

const scheduleJadwalNotifications = functions.pubsub
  .schedule("0 7 * * *")
  .timeZone("Asia/Makassar")
  .onRun(async () => {
    await runScheduleNotifications();
    return null;
  });

module.exports = { scheduleJadwalNotifications, runScheduleNotifications };
