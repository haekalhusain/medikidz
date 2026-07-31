class Pengguna {
  final String? id;
  final String nama;
  final String noHp;
  final String role;
  final String? email;
  final String? alamat;

  Pengguna({
    this.id,
    required this.nama,
    required this.noHp,
    required this.role,
    this.email,
    this.alamat,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json, String id) {
    return Pengguna(
      id: id,
      nama: json['nama'] ?? '',
      noHp: json['no_hp'] ?? '',
      role: json['role'] ?? 'user',
      email: json['email'],
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'no_hp': noHp,
        'role': role,
        'email': email,
        'alamat': alamat,
      };
}
