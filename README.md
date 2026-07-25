# Medikidz — Flutter + Firestore (Data Anak Input Manual oleh Admin)

## Perubahan dari versi sebelumnya
Data anak **tidak lagi** disinkronkan dari database vendor. Sekarang:
- Admin **input manual** data anak lewat form CRUD biasa
- Karena belum ada login/akun untuk orang tua, kontak orang tua (`nama_orang_tua`,
  `no_hp_orang_tua`) disimpan **langsung sebagai teks** di setiap data anak —
  bukan referensi ke akun user (`id_user`) seperti desain sebelumnya
- Menu "Data Anak" dipindah dari Dashboard Pengguna ke **Dashboard Admin**
- Dashboard Pengguna sekarang hanya berisi menu **lihat** (jadwal, artikel) — tidak ada CRUD data anak di sisi user

## Setup

### 1. Buat project Firebase & aktifkan Firestore
[Firebase Console](https://console.firebase.google.com) → Firestore Database (mode test).

### 2. Konek ke project Flutter
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Setelah itu un-comment 2 baris di `lib/main.dart`:
```dart
import 'firebase_options.dart';
// ...
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 3. `pubspec.yaml`
```yaml
dependencies:
  get: ^4.6.6
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
```

### 4. Firestore Security Rules (development only)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // ⚠️ HANYA untuk development
    }
  }
}
```

## Struktur Project
```
lib/
├── main.dart
├── models/
│   ├── vaksin_model.dart
│   ├── anak_model.dart           <- diubah: kontak ortu manual, bukan id_user
│   ├── jadwal_master_model.dart  <- toleransi editable admin
│   ├── jadwal_model.dart
│   ├── riwayat_model.dart
│   └── artikel_model.dart
├── services/
│   └── firestore_service.dart    <- generic, dipakai semua collection
├── controllers/
│   ├── vaksin_controller.dart
│   ├── anak_controller.dart      <- tidak ada lagi currentUserId dummy
│   ├── jadwal_master_controller.dart
│   └── jadwal_controller.dart
└── views/
    ├── role_selection_page.dart
    ├── admin/
    │   ├── admin_dashboard_page.dart   <- "Data Anak" ada di sini sekarang
    │   ├── vaksin/          (CRUD penuh)
    │   ├── anak/            (CRUD penuh, kontak ortu manual)
    │   └── jadwal_master/   (CRUD, fokus toleransi keterlambatan)
    └── user/
        ├── user_dashboard_page.dart    <- tanpa menu Data Anak
        └── jadwal/          (read-only)

seed/
└── jadwal_master_seed.json   (40 entri dari spreadsheet klinik)
```

## Modul yang Sudah Jadi Contoh Pattern Lengkap
1. **Vaksin** (admin, CRUD penuh)
2. **Anak** (admin, CRUD penuh + soft delete + kontak orang tua manual)
3. **Jadwal Master** (admin, fokus edit toleransi keterlambatan & kategori jendela pengejaran)
4. **Jadwal Imunisasi** (user, read-only)

Modul lain (Pengguna, Artikel, Riwayat, Antrian Notifikasi) belum dibuatkan UI — tinggal
copy pattern dari salah satu modul di atas yang paling mirip kebutuhannya:
- Butuh CRUD penuh → contoh Vaksin/Anak
- Butuh read-only → contoh Jadwal Imunisasi

## Import Seed Data Jadwal Master
Karena Firestore tidak punya bulk-import JSON native lewat CLI biasa, cara paling praktis
pakai script Node.js sekali jalan:
```javascript
// import_seed.js
const admin = require('firebase-admin');
const seed = require('./jadwal_master_seed.json');
admin.initializeApp({ credential: admin.credential.applicationDefault() });
const db = admin.firestore();

async function run() {
  const batch = db.batch();
  seed.forEach((item) => {
    const ref = db.collection('tb_jadwalMaster').doc();
    batch.set(ref, item);
  });
  await batch.commit();
  console.log(`Imported ${seed.length} entries.`);
}
run();
```
Butuh `npm install firebase-admin` dan service account key dari Firebase Console.

Setelah data masuk, buka menu **Jadwal Master** di app (Dashboard Admin) → tinjau &
sesuaikan toleransi keterlambatan tiap vaksin satu per satu.

## Catatan Penting
- **Belum ada validasi akses** — karena belum ada auth, siapa saja yang buka app bisa
  akses semua collection. Ini oke untuk development, **wajib diperbaiki** sebelum rilis
  (Firestore Security Rules berbasis `request.auth`).
- **Data anak sekarang sepenuhnya milik klinik** (diinput admin), bukan milik akun
  orang tua. Kalau nanti login orang tua sungguhan dibangun, perlu diputuskan ulang:
  apakah orang tua bisa "klaim" data anak yang sudah diinput admin (misal cocokkan
  lewat no HP), atau tetap 2 sumber data terpisah.
