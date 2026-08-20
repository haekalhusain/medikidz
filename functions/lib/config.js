// Ganti array ini untuk pindah skema notifikasi.
// Skema A (default): H-3, H-2, H-1, H-0  -> 4 notifikasi per dosis
// Skema B (hemat kuota): H-3, H-1, H-0    -> 3 notifikasi per dosis
const NOTIF_OFFSETS_SKEMA_A = [3, 2, 1, 0];
const NOTIF_OFFSETS_SKEMA_B = [3, 1, 0];

// <<< pilih skema aktif di sini >>>
const ACTIVE_NOTIF_OFFSETS = NOTIF_OFFSETS_SKEMA_A;

// Status realisasi yang berarti "tidak perlu diingatkan lagi"
const STATUS_TIDAK_PERLU_NOTIF = ["sudah imunisasi", "dilewati", "tidak bisa dikejar"];

const OFFSET_LABEL = { 3: "H-3", 2: "H-2", 1: "H-1", 0: "H-0" };

// Batas aman Firestore
const FIRESTORE_IN_CHUNK_SIZE = 30;
const BATCH_WRITE_CHUNK_SIZE = 450;

module.exports = {
  NOTIF_OFFSETS_SKEMA_A,
  NOTIF_OFFSETS_SKEMA_B,
  ACTIVE_NOTIF_OFFSETS,
  STATUS_TIDAK_PERLU_NOTIF,
  OFFSET_LABEL,
  FIRESTORE_IN_CHUNK_SIZE,
  BATCH_WRITE_CHUNK_SIZE,
};
