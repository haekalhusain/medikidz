import '../controllers/jadwal_controller.dart';
import '../controllers/vaksin_controller.dart';
import '../models/anak_model.dart';
import '../models/jadwal_model.dart';
import 'jadwal_schedule_service.dart';

/// Helper untuk menyimpan/mengubah status realisasi dari sebuah baris
/// jadwal yang DIHITUNG OTOMATIS (JadwalTerjadwal). Dipakai di halaman
/// manapun yang menampilkan rencana imunisasi (per-anak maupun lintas anak).
class JadwalStatusUpdater {
  static Future<bool> ubahStatus({
    required JadwalController jadwalController,
    required VaksinController vaksinController,
    required Anak anak,
    required JadwalTerjadwal item,
    required String status,
  }) async {
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
      return jadwalController.updateData(item.realisasi!.id!, updated);
    }

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
    return jadwalController.create(baru);
  }
}
