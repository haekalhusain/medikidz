# Medikidz Cloud Functions — versi efisien (sesuai skema Firestore yang sebenarnya)

## Kenapa didesain ulang
Versi sebelumnya sempat salah asumsi: mengira `tb_jadwalImunisasi` berisi 1 dokumen per
dosis untuk setiap anak. Kenyataannya (dicek dari `jadwal_status_updater.dart` &
`jadwal_model.dart`): dokumen di `tb_jadwalImunisasi` HANYA dibuat saat status dosis
diubah (sudah imunisasi / dilewati / tidak bisa dikejar) atau saat dijadwal ulang manual.
Dosis "belum imunisasi" (mayoritas) memang tidak punya dokumen — tanggal jatuh temponya
dihitung on-the-fly di Flutter dari `tanggal_lahir + usia_hari`. Versi ini mengikuti
skema itu apa adanya, tanpa menambah field/dokumen baru yang bisa bentrok dengan app.

## Yang berubah dari kode lama
- `scheduleJadwalNotifications`: 1x cron/hari, cek offset H-3/H-2/H-1/H-0 sekaligus.
  - Baca `tb_anak` HANYA yang `deleted_at == null` (bukan seluruh koleksi).
  - Hitung tanggal jatuh tempo "alami" di memori (tanggal_lahir + usia_hari), tanpa read.
  - Baru query `tb_jadwalImunisasi` secara TERARAH: (a) utk anak-anak yang punya dosis
    jatuh tempo hari ini (cek apakah sudah selesai/di-skip/di-reschedule), dan
    (b) dosis yang di-reschedule manual ke rentang H-3..H-0.
  - Tidak pernah `getAllDocuments()` / scan seluruh koleksi.
- Ganti skema notifikasi di `lib/config.js` (`ACTIVE_NOTIF_OFFSETS`).
- Batch write dipecah per 450 dokumen (aman dari limit 500 write/batch Firestore).

## Deploy
```bash
firebase deploy --only functions,firestore:indexes
```

## Catatan
Tidak perlu migrasi data lama — tidak ada field/dokumen baru yang didenormalisasi,
jadi `tb_jadwalImunisasi` dan `tb_anak` yang sudah ada bisa langsung dipakai apa adanya.
