import '../controllers/jadwal_controller.dart';
import '../controllers/vaksin_controller.dart';
import '../models/anak_model.dart';
import '../models/jadwal_model.dart';
import '../models/vaksin_model.dart';
import 'activity_log_service.dart';
import 'jadwal_schedule_service.dart';

/// Helper untuk menyimpan/mengubah status realisasi dari sebuah baris
/// jadwal yang DIHITUNG OTOMATIS (JadwalTerjadwal). Dipakai di halaman
/// manapun yang menampilkan rencana imunisasi (per-anak maupun lintas anak).
///
/// Kalau status diubah jadi "sudah imunisasi" DAN vaksinnya dari klinik
/// (bukan bawa sendiri), stok vaksin di tb_vaksin otomatis dikurangi 1.
class JadwalStatusUpdater {
  static Future<bool> ubahStatus({
    required JadwalController jadwalController,
    required VaksinController vaksinController,
    required Anak anak,
    required JadwalTerjadwal item,
    required String status,
    bool vaksinDariKlinik = false,
  }) async {
    bool success;

    if (item.realisasi != null) {
      final updated = JadwalImunisasi(
        id: item.realisasi!.id,
        idAnak: item.realisasi!.idAnak,
        idVaksin: item.realisasi!.idVaksin,
        tanggalImunisasi:
            status == 'sudah imunisasi' ? DateTime.now() : item.realisasi!.tanggalImunisasi,
        status: status,
        namaAnak: item.realisasi!.namaAnak,
        namaVaksin: item.realisasi!.namaVaksin,
        urutanDosis: item.realisasi!.urutanDosis,
      );
      success = await jadwalController.updateData(item.realisasi!.id!, updated);
    } else {
      // Belum ada dokumen realisasi. Kalau targetnya "belum imunisasi",
      // tidak perlu bikin dokumen kosong -- itu memang default-nya.
      if (status != 'sudah imunisasi') return true;

      String idVaksin = '';
      try {
        idVaksin = vaksinController.vaksinList
            .firstWhere((v) => v.namaVaksin.toLowerCase() == item.master.namaVaksin.toLowerCase())
            .id!;
      } catch (_) {
        // Vaksin belum ada di data stok -- tetap simpan, id_vaksin dikosongkan.
      }

      final baru = JadwalImunisasi(
        idAnak: anak.id!,
        idVaksin: idVaksin,
        tanggalImunisasi: DateTime.now(),
        status: 'sudah imunisasi',
        namaAnak: anak.namaAnak,
        namaVaksin: item.master.namaVaksin,
        urutanDosis: item.master.urutanDosis,
      );
      success = await jadwalController.create(baru);
    }

    if (success && status == 'sudah imunisasi') {
      await ActivityLogService.log(
        'Mencatat imunisasi ${item.master.namaVaksin} (Dosis ${item.master.urutanDosis}) untuk ${anak.namaAnak}',
        kategori: 'imunisasi',
      );

      if (vaksinDariKlinik) {
        await _kurangiStok(vaksinController, item.master.namaVaksin);
      }
    }

    return success;
  }

  static Future<void> _kurangiStok(VaksinController vaksinController, String namaVaksin) async {
    try {
      final vaksin = vaksinController.vaksinList
          .firstWhere((v) => v.namaVaksin.toLowerCase() == namaVaksin.toLowerCase());

      final stokBaru = (vaksin.jumlahStok - 1) < 0 ? 0 : vaksin.jumlahStok - 1;
      final statusBaru = stokBaru == 0 ? 'kosong' : (stokBaru <= 5 ? 'menipis' : 'tersedia');

      final updated = Vaksin(
        id: vaksin.id,
        namaVaksin: vaksin.namaVaksin,
        kategoriVaksin: vaksin.kategoriVaksin,
        jumlahStok: stokBaru,
        statusStok: statusBaru,
        informasi: vaksin.informasi,
      );

      await vaksinController.updateData(vaksin.id!, updated);
      await ActivityLogService.log(
        'Stok $namaVaksin berkurang 1 (sisa $stokBaru) karena dipakai imunisasi di klinik',
        kategori: 'vaksin',
      );
    } catch (_) {
      // Vaksin tidak ditemukan di data stok -- tidak fatal, cuma dilewati.
    }
  }
}
