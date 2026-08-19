import 'konten_section_model.dart';

class Artikel {
  final String? id;
  final String judul;
  final String kategori;
  final String ringkasan;
  final String? gambarUrl;
  final List<KontenSection> konten;
  final DateTime tanggalUpload;
  final String status; // 'draft' | 'dipublikasi' | 'arsip'
  final String penulis; // otomatis diisi nama admin yang login saat create

  Artikel({
    this.id,
    required this.judul,
    required this.kategori,
    required this.ringkasan,
    this.gambarUrl,
    this.konten = const [],
    required this.tanggalUpload,
    this.status = 'draft',
    this.penulis = '-',
  });

  String get statusLabel {
    switch (status) {
      case 'dipublikasi':
        return 'Dipublikasi';
      case 'arsip':
        return 'Arsip';
      default:
        return 'Draft';
    }
  }

  static String? _normalizeGambarUrl(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    // i.ibb.co punya masalah SSL cert (NET::ERR_CERT_COMMON_NAME_INVALID)
    // di beberapa device/jaringan. i.ibb.co.com aman dan sudah terbukti
    // jalan normal di Dapoer Rasa.
    return value.replaceFirst('i.ibb.co/', 'i.ibb.co.com/');
  }

  factory Artikel.fromJson(Map<String, dynamic> json, String id) {
    return Artikel(
      id: id,
      judul: json['judul'] ?? '',
      kategori: json['kategori'] ?? '',
      ringkasan: json['ringkasan'] ?? '',
      gambarUrl: _normalizeGambarUrl(json['gambar_url']),
      konten: (json['konten'] as List<dynamic>? ?? [])
          .map((e) => KontenSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      tanggalUpload: json['tanggal_upload'] != null
          ? DateTime.parse(json['tanggal_upload'])
          : DateTime.now(),
      status: json['status'] ?? 'draft',
      penulis: json['penulis'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() => {
        'judul': judul,
        'kategori': kategori,
        'ringkasan': ringkasan,
        'gambar_url': gambarUrl,
        'konten': konten.map((e) => e.toJson()).toList(),
        'tanggal_upload': tanggalUpload.toIso8601String(),
        'status': status,
        'penulis': penulis,
      };
}
