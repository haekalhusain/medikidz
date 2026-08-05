class Notifikasi {
  final String? id;
  final String uid;
  final String judul;
  final String pesan;
  final String kategori; // 'jadwal' | 'artikel' | 'akun'
  final DateTime waktu;
  final bool terbaca;

  Notifikasi({
    this.id,
    required this.uid,
    required this.judul,
    required this.pesan,
    required this.kategori,
    required this.waktu,
    this.terbaca = false,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json, String id) {
    return Notifikasi(
      id: id,
      uid: json['uid'] ?? '',
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      kategori: json['kategori'] ?? 'umum',
      waktu: json['waktu'] != null ? DateTime.parse(json['waktu']) : DateTime.now(),
      terbaca: json['terbaca'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'judul': judul,
        'pesan': pesan,
        'kategori': kategori,
        'waktu': waktu.toIso8601String(),
        'terbaca': terbaca,
      };
}
