import 'konten_section_model.dart';

class Vaksin {
  final String? id;
  final String namaVaksin;
  final String kategoriVaksin; // contoh: 'Program Pemerintahan (Imunisasi Rutin Wajib)', 'Program Mandiri (Pilihan)'
  final int jumlahStok;
  final String statusStok; // 'tersedia' | 'menipis' | 'kosong'
  final List<KontenSection> informasi; // blok Subjudul+Isi, bisa lebih dari 1

  Vaksin({
    this.id,
    required this.namaVaksin,
    required this.kategoriVaksin,
    required this.jumlahStok,
    required this.statusStok,
    this.informasi = const [],
  });

  /// Label tampilan status, dipakai di list card.
  String get statusLabel {
    switch (statusStok) {
      case 'tersedia':
        return 'Tersedia';
      case 'menipis':
        return 'Stok Menipis';
      case 'kosong':
        return 'Kosong';
      default:
        return statusStok;
    }
  }

  factory Vaksin.fromJson(Map<String, dynamic> json, String id) {
    return Vaksin(
      id: id,
      namaVaksin: json['nama_vaksin'] ?? '',
      kategoriVaksin: json['kategori_vaksin'] ?? '',
      jumlahStok: json['jumlah_stok'] ?? 0,
      statusStok: json['status_stok'] ?? 'tersedia',
      informasi: (json['informasi'] as List<dynamic>? ?? [])
          .map((e) => KontenSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_vaksin': namaVaksin,
        'kategori_vaksin': kategoriVaksin,
        'jumlah_stok': jumlahStok,
        'status_stok': statusStok,
        'informasi': informasi.map((e) => e.toJson()).toList(),
      };
}
