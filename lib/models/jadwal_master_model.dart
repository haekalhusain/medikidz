class JadwalMaster {
  final String? id;
  final String namaVaksin;
  final int urutanDosis;
  final int usiaHari;
  final String usiaLabel;
  final String kategori;
  final String kategoriJendelaPengejaran;
  final int? toleransiKeterlambatanHari;
  final String? catatanMedis;
  final String? sumberReferensi;
  final int? intervalMinimumPengejaranHari;
  final int? usiaMaksimalHari;

  JadwalMaster({
    this.id,
    required this.namaVaksin,
    required this.urutanDosis,
    required this.usiaHari,
    required this.usiaLabel,
    required this.kategori,
    required this.kategoriJendelaPengejaran,
    this.toleransiKeterlambatanHari,
    this.catatanMedis,
    this.sumberReferensi,
    this.intervalMinimumPengejaranHari,
    this.usiaMaksimalHari,
  });

  factory JadwalMaster.fromJson(Map<String, dynamic> json, String id) {
    return JadwalMaster(
      id: id,
      namaVaksin: json['nama_vaksin'] ?? '',
      urutanDosis: json['urutan_dosis'] ?? 1,
      usiaHari: json['usia_hari'] ?? 0,
      usiaLabel: json['usia_label'] ?? '',
      kategori: json['kategori'] ?? 'wajib',
      kategoriJendelaPengejaran: json['kategori_jendela_pengejaran'] ?? 'terbatas',
      toleransiKeterlambatanHari: json['toleransi_keterlambatan_hari'],
      catatanMedis: json['catatan_medis'],
      sumberReferensi: json['sumber_referensi'],
      intervalMinimumPengejaranHari: json['interval_minimum_pengejaran_hari'],
      usiaMaksimalHari: json['usia_maksimal_hari'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_vaksin': namaVaksin,
        'urutan_dosis': urutanDosis,
        'usia_hari': usiaHari,
        'usia_label': usiaLabel,
        'kategori': kategori,
        'kategori_jendela_pengejaran': kategoriJendelaPengejaran,
        'toleransi_keterlambatan_hari': toleransiKeterlambatanHari,
        'catatan_medis': catatanMedis,
        'sumber_referensi': sumberReferensi,
        'interval_minimum_pengejaran_hari': intervalMinimumPengejaranHari,
        'usia_maksimal_hari': usiaMaksimalHari,
      };
}
