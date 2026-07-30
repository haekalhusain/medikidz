import 'package:cloud_firestore/cloud_firestore.dart';

/// Layanan sederhana buat mencatat aktivitas admin ke Firestore
/// (dipakai di panel "Aktivitas Terbaru" dashboard). Gagal mencatat log
/// TIDAK BOLEH mengganggu alur utama (create vaksin/artikel/imunisasi),
/// makanya semua error di sini ditelan diam-diam.
class ActivityLogService {
  static final _collection = FirebaseFirestore.instance.collection('tb_activityLog');

  static Future<void> log(String pesan, {String kategori = 'umum'}) async {
    try {
      await _collection.add({
        'pesan': pesan,
        'kategori': kategori,
        'waktu': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // sengaja diabaikan
    }
  }

  static Stream<List<ActivityLogEntry>> streamTerbaru({int limit = 8}) {
    return _collection.orderBy('waktu', descending: true).limit(limit).snapshots().map(
          (snap) => snap.docs.map((d) => ActivityLogEntry.fromJson(d.data())).toList(),
        );
  }
}

class ActivityLogEntry {
  final String pesan;
  final String kategori;
  final DateTime waktu;

  ActivityLogEntry({required this.pesan, required this.kategori, required this.waktu});

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      pesan: json['pesan'] ?? '',
      kategori: json['kategori'] ?? 'umum',
      waktu: json['waktu'] != null ? DateTime.parse(json['waktu']) : DateTime.now(),
    );
  }
}
