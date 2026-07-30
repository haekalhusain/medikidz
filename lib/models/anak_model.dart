class Anak {
  final String? id;
  final String idUser;
  final String namaAnak;
  final DateTime tanggalLahir;
  final String jenisKelamin;
  final String? nik;
  final bool isDeleted;

  Anak({
    this.id,
    required this.idUser,
    required this.namaAnak,
    required this.tanggalLahir,
    required this.jenisKelamin,
    this.nik,
    this.isDeleted = false,
  });

  factory Anak.fromJson(Map<String, dynamic> json, String id) {
    return Anak(
      id: id,
      idUser: json['id_user'] ?? '',
      namaAnak: json['nama_anak'] ?? '',
      tanggalLahir: json['tanggal_lahir'] != null
          ? DateTime.parse(json['tanggal_lahir'])
          : DateTime.now(),
      jenisKelamin: json['jenis_kelamin'] ?? 'laki-laki',
      nik: json['nik'],
      isDeleted: json['deleted_at'] != null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_user': idUser,
        'nama_anak': namaAnak,
        'tanggal_lahir': tanggalLahir.toIso8601String(),
        'jenis_kelamin': jenisKelamin,
        'nik': nik,
        'deleted_at': null,
      };
}
