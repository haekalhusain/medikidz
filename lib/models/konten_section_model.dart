/// Satu blok konten "Subjudul + Isi" — dipakai berulang di form Vaksin
/// dan Artikel (sesuai desain: "Tambah Konten Artikel" bisa diklik berkali-kali
/// untuk menambah blok Subjudul 2, Subjudul 3, dst).
class KontenSection {
  final String subjudul;
  final String isi;

  KontenSection({required this.subjudul, required this.isi});

  factory KontenSection.fromJson(Map<String, dynamic> json) {
    return KontenSection(
      subjudul: json['subjudul'] ?? '',
      isi: json['isi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'subjudul': subjudul, 'isi': isi};
}
