class Vaksin {
  final String? id;
  final String namaVaksin;
  final String usiaImunisasi;
  final int jumlahStok;
  final String statusStok; // 'tersedia' | 'menipis' | 'habis'

  Vaksin({
    this.id,
    required this.namaVaksin,
    required this.usiaImunisasi,
    required this.jumlahStok,
    required this.statusStok,
  });

  factory Vaksin.fromJson(Map<String, dynamic> json, String id) {
    return Vaksin(
      id: id,
      namaVaksin: json['nama_vaksin'] ?? '',
      usiaImunisasi: json['usia_imunisasi'] ?? '',
      jumlahStok: json['jumlah_stok'] ?? 0,
      statusStok: json['status_stok'] ?? 'tersedia',
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_vaksin': namaVaksin,
        'usia_imunisasi': usiaImunisasi,
        'jumlah_stok': jumlahStok,
        'status_stok': statusStok,
      };
}
