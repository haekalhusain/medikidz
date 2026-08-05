const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const { v4: uuidv4 } = require("uuid");
const bcrypt = require("bcryptjs");

admin.initializeApp();
const db = admin.firestore();

function parseDateField(value) {
  if (!value) return null;
  if (value instanceof admin.firestore.Timestamp) return value.toDate();
  if (typeof value === 'string' || value instanceof String) return new Date(value.toString());
  if (value instanceof Date) return value;
  return null;
}

function toIsoDateString(date) {
  return date.toISOString().split('T')[0];
}

function sameDate(a, b) {
  return a.getUTCFullYear() === b.getUTCFullYear() &&
    a.getUTCMonth() === b.getUTCMonth() &&
    a.getUTCDate() === b.getUTCDate();
}

async function getAllDocuments(path) {
  const snapshot = await db.collection(path).get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

const SESSION_COLLECTION = "_registrasi_sessions";
const OTP_EXPIRY_MINUTES = 5;
const SESSION_EXPIRY_MINUTES = 15;

const FONNTE_TOKEN = functions.config().fonnte?.token || "GANTI_DENGAN_TOKEN_FONNTE";

function normalizePhone(phone) {
  let cleaned = phone.replace(/\D/g, "");
  if (cleaned.startsWith("0")) cleaned = "62" + cleaned.substring(1);
  return cleaned;
}

async function sendWhatsAppOtp(phone, otp) {
  await axios.post(
    "https://api.fonnte.com/send",
    { target: phone, message: `Kode verifikasi Medikidz Anda: ${otp}\n\nJangan berikan kode ini kepada siapapun. Berlaku ${OTP_EXPIRY_MINUTES} menit.` },
    { headers: { Authorization: FONNTE_TOKEN } }
  );
}

exports.register = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({ success: false, message: "Method not allowed" });

  const { no_hp, tanggal_lahir, nama_orang_tua, nama_anak, tanggal_lahir_anak, jenis_kelamin_anak } = req.body;

  if (!no_hp || !tanggal_lahir || !nama_orang_tua || !nama_anak || !tanggal_lahir_anak || !jenis_kelamin_anak) {
    return res.status(400).json({ success: false, message: "Semua field wajib diisi." });
  }

  const phone = normalizePhone(no_hp);

  const existing = await db.collection("tb_pengguna").where("no_hp", "==", phone).limit(1).get();
  if (!existing.empty) {
    return res.status(409).json({ success: false, message: "Nomor HP ini sudah terdaftar. Silakan login." });
  }

  const registrationToken = uuidv4();
  const otp = Math.floor(100000 + Math.random() * 900000);

  await db.collection(SESSION_COLLECTION).doc(registrationToken).set({
    no_hp: phone,
    tanggal_lahir,
    nama_orang_tua,
    nama_anak,
    tanggal_lahir_anak,
    jenis_kelamin_anak,
    otp_code: otp,
    otp_attempts: 0,
    expires_at: admin.firestore.Timestamp.fromMillis(Date.now() + SESSION_EXPIRY_MINUTES * 60 * 1000),
  });

  await sendWhatsAppOtp(phone, otp);

  return res.status(200).json({ success: true, data: { registration_token: registrationToken } });
});

exports.resendOtp = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({ success: false, message: "Method not allowed" });

  const { registration_token } = req.body;
  const ref = db.collection(SESSION_COLLECTION).doc(registration_token);
  const doc = await ref.get();

  if (!doc.exists) return res.status(410).json({ success: false, message: "Sesi registrasi kadaluarsa." });

  const data = doc.data();
  const otp = Math.floor(100000 + Math.random() * 900000);

  await ref.update({ otp_code: otp, otp_attempts: 0 });
  await sendWhatsAppOtp(data.no_hp, otp);

  return res.status(200).json({ success: true, message: "Kode OTP baru telah dikirim." });
});

exports.verifyOtp = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") return res.status(405).json({ success: false, message: "Method not allowed" });

  const { registration_token, otp, password } = req.body;

  if (!registration_token || !otp || !password || password.length < 8) {
    return res.status(400).json({ success: false, message: "Data tidak lengkap / password minimal 8 karakter." });
  }

  const sessionRef = db.collection(SESSION_COLLECTION).doc(registration_token);
  const sessionDoc = await sessionRef.get();

  if (!sessionDoc.exists) return res.status(410).json({ success: false, message: "Sesi kadaluarsa." });

  const session = sessionDoc.data();

  if (session.otp_attempts >= 3) {
    return res.status(429).json({ success: false, message: "Terlalu banyak percobaan, minta OTP baru." });
  }

  if (String(session.otp_code) !== String(otp)) {
    await sessionRef.update({ otp_attempts: admin.firestore.FieldValue.increment(1) });
    return res.status(422).json({ success: false, message: "Kode OTP salah." });
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const penggunaRef = db.collection("tb_pengguna").doc();
  const anakRef = db.collection("tb_anak").doc();

  const batch = db.batch();

  batch.set(penggunaRef, {
    nama: session.nama_orang_tua,
    no_hp: session.no_hp,
    tanggal_lahir: session.tanggal_lahir,
    role: "user",
    password_hash: passwordHash,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  batch.set(anakRef, {
    id_user: penggunaRef.id,
    nama_anak: session.nama_anak,
    tanggal_lahir: session.tanggal_lahir_anak,
    jenis_kelamin: session.jenis_kelamin_anak,
    deleted_at: null,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();
  await sessionRef.delete();

  return res.status(201).json({ success: true, data: { id_user: penggunaRef.id, id_anak: anakRef.id } });
});

exports.scheduleJadwalH3Notifications = functions.pubsub
  .schedule('0 7 * * *')
  .timeZone('Asia/Makassar')
  .onRun(async () => {
    const now = new Date();
    const targetDay = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
    targetDay.setUTCDate(targetDay.getUTCDate() + 3);
    const targetDateString = toIsoDateString(targetDay);

    const [anakList, masterList, jadwalList, existingNotifSnapshot] = await Promise.all([
      getAllDocuments('tb_anak'),
      getAllDocuments('tb_jadwalMaster'),
      getAllDocuments('tb_jadwalImunisasi'),
      db.collection('tb_notifikasi')
        .where('kategori', '==', 'jadwal')
        .where('jadwal_tanggal', '==', targetDateString)
        .get(),
    ]);

    const existingKeys = new Set();
    existingNotifSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      const key = `${data.uid || ''}|${(data.jadwal_nama_vaksin || '').toString().toLowerCase()}|${data.jadwal_urutan_dosis || ''}|${data.jadwal_tanggal || ''}`;
      existingKeys.add(key);
    });

    const batch = db.batch();
    let createdCount = 0;

    for (const anak of anakList) {
      if (!anak.id_user || !anak.nama_anak || !anak.tanggal_lahir || anak.deleted_at) continue;
      const tanggalLahir = parseDateField(anak.tanggal_lahir);
      if (!tanggalLahir) continue;

      for (const master of masterList) {
        if (!master.nama_vaksin || master.usia_hari == null || master.urutan_dosis == null) continue;

        let tanggalJadwal = new Date(tanggalLahir.getTime());
        tanggalJadwal.setUTCDate(tanggalJadwal.getUTCDate() + master.usia_hari);

        const cocokRealisasi = jadwalList.find((r) => {
          const namaCocok = (r.nama_vaksin || '').toString().toLowerCase() === master.nama_vaksin.toString().toLowerCase();
          const dosisCocok = r.urutan_dosis == null || r.urutan_dosis === master.urutan_dosis;
          return r.id_anak === anak.id && namaCocok && dosisCocok;
        });

        if (cocokRealisasi) {
          if (cocokRealisasi.tanggal_rencana_override) {
            const overrideDate = parseDateField(cocokRealisasi.tanggal_rencana_override);
            if (overrideDate) tanggalJadwal = overrideDate;
          }

          if (['sudah imunisasi', 'dilewati', 'tidak bisa dikejar'].includes((cocokRealisasi.status || '').toString().toLowerCase())) {
            continue;
          }
        }

        if (!sameDate(tanggalJadwal, targetDay)) continue;

        const jadwalKey = `${anak.id_user}|${master.nama_vaksin.toString().toLowerCase()}|${master.urutan_dosis}|${targetDateString}`;
        if (existingKeys.has(jadwalKey)) continue;

        const pesan = `Imunisasi ${master.nama_vaksin} untuk ${anak.nama_anak} dijadwalkan tanggal ${targetDateString}. Persiapkan ya!`;
        const notifRef = db.collection('tb_notifikasi').doc();
        batch.set(notifRef, {
          uid: anak.id_user,
          judul: `Pengingat Imunisasi ${master.nama_vaksin}`,
          pesan,
          kategori: 'jadwal',
          waktu: admin.firestore.Timestamp.now(),
          jadwal_tanggal: targetDateString,
          jadwal_nama_vaksin: master.nama_vaksin,
          jadwal_urutan_dosis: master.urutan_dosis,
          source: 'auto_h3',
        });
        existingKeys.add(jadwalKey);
        createdCount += 1;
      }
    }

    if (createdCount > 0) {
      await batch.commit();
      console.log(`Created ${createdCount} automatic H-3 jadwal notifications.`);
    } else {
      console.log('No H-3 jadwal notifications to create today.');
    }

    return null;
  });

exports.sendFcmOnNotificationCreate = functions.firestore
  .document('tb_notifikasi/{notifikasiId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    if (!data) return null;

    const uid = data.uid;
    if (!uid) return null;

    const penggunaDoc = await db.collection('tb_pengguna').doc(uid).get();
    if (!penggunaDoc.exists) return null;

    const penggunaData = penggunaDoc.data();
    if (!penggunaData || !penggunaData.fcm_token) return null;

    const message = {
      token: penggunaData.fcm_token,
      notification: {
        title: data.judul || 'Notifikasi Medikidz',
        body: data.pesan || '',
      },
      data: {
        kategori: data.kategori || 'jadwal',
        notifikasiId: snapshot.id,
      },
    };

    try {
      await admin.messaging().send(message);
    } catch (error) {
      console.error('FCM send error:', error);
    }

    return null;
  });
