class Pengguna {
  final String? id;
  final String nama;
  final String noHp;
  final String role;

  Pengguna({this.id, required this.nama, required this.noHp, required this.role});

  factory Pengguna.fromJson(Map<String, dynamic> json, String id) {
    return Pengguna(
      id: id,
      nama: json['nama'] ?? '',
      noHp: json['no_hp'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {'nama': nama, 'no_hp': noHp, 'role': role};
}
