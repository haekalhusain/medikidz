class JadwalImunisasi {
  final String? id;
  final String idAnak;
  final String idVaksin;
  final DateTime tanggalImunisasi;
  final String status;
  final String? namaAnak;
  final String? namaVaksin;
  final int? urutanDosis;

  JadwalImunisasi({
    this.id,
    required this.idAnak,
    required this.idVaksin,
    required this.tanggalImunisasi,
    this.status = 'belum imunisasi',
    this.namaAnak,
    this.namaVaksin,
    this.urutanDosis,
  });

  factory JadwalImunisasi.fromJson(Map<String, dynamic> json, String id) {
    return JadwalImunisasi(
      id: id,
      idAnak: json['id_anak'] ?? '',
      idVaksin: json['id_vaksin'] ?? '',
      tanggalImunisasi: json['tanggal_imunisasi'] != null
          ? DateTime.parse(json['tanggal_imunisasi'])
          : DateTime.now(),
      status: json['status'] ?? 'belum imunisasi',
      namaAnak: json['nama_anak'],
      namaVaksin: json['nama_vaksin'],
      urutanDosis: json['urutan_dosis'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id_anak': idAnak,
        'id_vaksin': idVaksin,
        'tanggal_imunisasi': tanggalImunisasi.toIso8601String(),
        'status': status,
        'nama_anak': namaAnak,
        'nama_vaksin': namaVaksin,
        'urutan_dosis': urutanDosis,
      };
}
