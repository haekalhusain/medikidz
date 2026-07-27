import 'konten_section_model.dart';

class Artikel {
  final String? id;
  final String judul;
  final String kategori; // contoh: 'Info Vaksin', 'Tips Kesehatan', 'Nutrisi', 'Tumbuh Kembang'
  final String ringkasan;
  final String? gambarUrl; // URL hasil upload ke Firebase Storage, nullable
  final List<KontenSection> konten;
  final DateTime tanggalUpload;

  Artikel({
    this.id,
    required this.judul,
    required this.kategori,
    required this.ringkasan,
    this.gambarUrl,
    this.konten = const [],
    required this.tanggalUpload,
  });

  factory Artikel.fromJson(Map<String, dynamic> json, String id) {
    return Artikel(
      id: id,
      judul: json['judul'] ?? '',
      kategori: json['kategori'] ?? '',
      ringkasan: json['ringkasan'] ?? '',
      gambarUrl: json['gambar_url'],
      konten: (json['konten'] as List<dynamic>? ?? [])
          .map((e) => KontenSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      tanggalUpload: json['tanggal_upload'] != null
          ? DateTime.parse(json['tanggal_upload'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'judul': judul,
        'kategori': kategori,
        'ringkasan': ringkasan,
        'gambar_url': gambarUrl,
        'konten': konten.map((e) => e.toJson()).toList(),
        'tanggal_upload': tanggalUpload.toIso8601String(),
      };
}
