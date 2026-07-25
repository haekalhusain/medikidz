import '../models/anak_model.dart';
import '../models/jadwal_master_model.dart';
import '../models/jadwal_model.dart';

/// Satu baris rencana imunisasi untuk seorang anak: gabungan antara
/// template (JadwalMaster) dengan realisasi aktualnya (JadwalImunisasi),
/// kalau sudah pernah dicatat.
class JadwalTerjadwal {
  final JadwalMaster master;
  final DateTime tanggalJadwal;
  final JadwalImunisasi? realisasi;

  JadwalTerjadwal({required this.master, required this.tanggalJadwal, this.realisasi});

  bool get sudah => realisasi != null && realisasi!.status == 'sudah imunisasi';

  String get statusLabel {
    if (sudah) return 'Sudah';
    if (tanggalJadwal.isBefore(DateTime.now())) return 'Terlambat';
    return 'Akan Datang';
  }
}

/// Menghitung rencana imunisasi 0-24 bulan seorang anak berdasarkan
/// tb_jadwalMaster (template usia per dosis) dan tanggal lahirnya,
/// lalu mencocokkan dengan tb_jadwalImunisasi (realisasi) yang sudah tercatat.
///
/// Ini murni kalkulasi di client — tidak ada yang ditulis ke Firestore,
/// jadi aman dipanggil berkali-kali (mis. tiap kali dashboard di-refresh).
class JadwalScheduleService {
  List<JadwalTerjadwal> computeJadwalForAnak({
    required Anak anak,
    required List<JadwalMaster> masterList,
    required List<JadwalImunisasi> semuaJadwalImunisasi,
  }) {
    final realisasiAnak = semuaJadwalImunisasi.where((j) => j.idAnak == anak.id).toList();

    final sorted = [...masterList]..sort((a, b) => a.usiaHari.compareTo(b.usiaHari));

    return sorted.map((master) {
      final tanggalJadwal = anak.tanggalLahir.add(Duration(days: master.usiaHari));

      JadwalImunisasi? realisasi;
      for (final r in realisasiAnak) {
        final namaCocok = r.namaVaksin == master.namaVaksin;
        final dosisCocok = r.urutanDosis == null || r.urutanDosis == master.urutanDosis;
        if (namaCocok && dosisCocok) {
          realisasi = r;
          break;
        }
      }

      return JadwalTerjadwal(master: master, tanggalJadwal: tanggalJadwal, realisasi: realisasi);
    }).toList();
  }

  /// Hitung berapa dosis (lintas SEMUA anak) yang jadwalnya jatuh di bulan
  /// & tahun tertentu dan belum direalisasikan. Dipakai di dashboard admin.
  int countJadwalBulanIni({
    required List<Anak> anakList,
    required List<JadwalMaster> masterList,
    required List<JadwalImunisasi> semuaJadwalImunisasi,
    required DateTime bulan,
  }) {
    var count = 0;
    for (final anak in anakList) {
      final jadwal = computeJadwalForAnak(
        anak: anak,
        masterList: masterList,
        semuaJadwalImunisasi: semuaJadwalImunisasi,
      );
      count += jadwal
          .where((j) =>
              !j.sudah && j.tanggalJadwal.year == bulan.year && j.tanggalJadwal.month == bulan.month)
          .length;
    }
    return count;
  }
}
