class RiwayatImunisasi {
  final String? id;
  final String idAnak;
  final String namaAnak; // denormalized, biar list tidak perlu join manual
  final String namaVaksin; // bebas teks — riwayat luar faskes belum tentu cocok nama vaksin di tb_vaksin
  final DateTime tanggalImunisasi;
  final String faskes; // nama faskes/dokter tempat imunisasi dilakukan
  final String? catatan;
  final bool isDeleted;

  RiwayatImunisasi({
    this.id,
    required this.idAnak,
    required this.namaAnak,
    required this.namaVaksin,
    required this.tanggalImunisasi,
    required this.faskes,
    this.catatan,
    this.isDeleted = false,
  });

  factory RiwayatImunisasi.fromJson(Map<String, dynamic> json, String id) {
    return RiwayatImunisasi(
      id: id,
      idAnak: json['id_anak'] ?? '',
      namaAnak: json['nama_anak'] ?? '',
      namaVaksin: json['nama_vaksin'] ?? '',
      tanggalImunisasi: json['tanggal_imunisasi'] != null
          ? DateTime.parse(json['tanggal_imunisasi'])
          : DateTime.now(),
      faskes: json['faskes'] ?? '',
      catatan: json['catatan'],
      isDeleted: json['deleted_at'] != null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_anak': idAnak,
        'nama_anak': namaAnak,
        'nama_vaksin': namaVaksin,
        'tanggal_imunisasi': tanggalImunisasi.toIso8601String(),
        'faskes': faskes,
        'catatan': catatan,
        'deleted_at': null,
      };
}
