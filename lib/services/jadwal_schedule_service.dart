import '../models/anak_model.dart';
import '../models/jadwal_master_model.dart';
import '../models/jadwal_model.dart';
import '../models/vaksin_model.dart';

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

/// Ringkasan kebutuhan SATU jenis vaksin untuk periode tertentu (biasanya
/// 1 bulan), dibandingkan dengan stok yang tersedia di tb_vaksin.
class KebutuhanVaksin {
  final String namaVaksin;
  final int dibutuhkan;
  final int stokTersedia;
  final bool terdaftarDiStok;

  KebutuhanVaksin({
    required this.namaVaksin,
    required this.dibutuhkan,
    required this.stokTersedia,
    required this.terdaftarDiStok,
  });

  /// Berapa dosis yang masih kurang. 0 kalau stok cukup/berlebih.
  int get kekurangan => (dibutuhkan - stokTersedia) > 0 ? dibutuhkan - stokTersedia : 0;

  bool get cukup => kekurangan == 0;
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

  /// Hitung kebutuhan vaksin PER JENIS untuk bulan & tahun tertentu, lintas
  /// SEMUA anak, lalu bandingkan dengan stok yang ada di tb_vaksin.
  ///
  /// Yang dihitung hanya jadwal yang jatuh di bulan tsb dan BELUM
  /// direalisasikan ('sudah imunisasi') -- sama seperti countJadwalBulanIni,
  /// hanya saja di sini dipecah per nama vaksin.
  List<KebutuhanVaksin> hitungKebutuhanVaksin({
    required List<Anak> anakList,
    required List<JadwalMaster> masterList,
    required List<JadwalImunisasi> semuaJadwalImunisasi,
    required List<Vaksin> vaksinList,
    required DateTime bulan,
  }) {
    // Langkah 1: kumpulkan semua baris jadwal (lintas anak) yang jatuh
    // di bulan target dan belum diimunisasi.
    final kebutuhanPerNama = <String, int>{};
    for (final anak in anakList) {
      final jadwal = computeJadwalForAnak(
        anak: anak,
        masterList: masterList,
        semuaJadwalImunisasi: semuaJadwalImunisasi,
      );

      for (final j in jadwal) {
        final cocokBulan =
            j.tanggalJadwal.year == bulan.year && j.tanggalJadwal.month == bulan.month;
        if (j.sudah || !cocokBulan) continue;

        kebutuhanPerNama.update(
          j.master.namaVaksin,
          (jumlah) => jumlah + 1,
          ifAbsent: () => 1,
        );
      }
    }

    // Langkah 2: cocokkan tiap nama vaksin dengan data stok (case-insensitive,
    // karena penulisan nama vaksin di jadwal master & tb_vaksin bisa beda kapital).
    final hasil = kebutuhanPerNama.entries.map((entry) {
      Vaksin? vaksinCocok;
      for (final v in vaksinList) {
        if (v.namaVaksin.toLowerCase() == entry.key.toLowerCase()) {
          vaksinCocok = v;
          break;
        }
      }

      return KebutuhanVaksin(
        namaVaksin: entry.key,
        dibutuhkan: entry.value,
        stokTersedia: vaksinCocok?.jumlahStok ?? 0,
        terdaftarDiStok: vaksinCocok != null,
      );
    }).toList();

    // Urutkan: yang paling kurang stoknya muncul paling atas, biar admin
    // langsung lihat prioritas restock.
    hasil.sort((a, b) => b.kekurangan.compareTo(a.kekurangan));
    return hasil;
  }
}
