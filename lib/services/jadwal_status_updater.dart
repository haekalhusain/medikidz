import '../controllers/jadwal_controller.dart';
import '../controllers/vaksin_controller.dart';
import '../models/anak_model.dart';
import '../models/jadwal_model.dart';
import '../models/vaksin_model.dart';
import '../models/notifikasi_model.dart';
import '../utils/date_formatter.dart';
import 'activity_log_service.dart';
import 'jadwal_schedule_service.dart';
import 'notifikasi_service.dart';

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
        tanggalRencanaOverride: item.realisasi!.tanggalRencanaOverride,
      );
      success = await jadwalController.updateData(item.realisasi!.id!, updated);
    } else {
      // Belum ada dokumen realisasi. Kalau targetnya "belum imunisasi",
      // tidak perlu bikin dokumen kosong -- itu memang default-nya.
      if (status == 'belum imunisasi') return true;

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
        status: status,
        namaAnak: anak.namaAnak,
        namaVaksin: item.master.namaVaksin,
        urutanDosis: item.master.urutanDosis,
      );
      success = await jadwalController.create(baru);
    }

    if (!success) return false;

    switch (status) {
      case 'sudah imunisasi':
        await ActivityLogService.log(
          'Mencatat imunisasi ${item.master.namaVaksin} (Dosis ${item.master.urutanDosis}) untuk ${anak.namaAnak}',
          kategori: 'imunisasi',
        );
        await NotifikasiService().createForUser(
          anak.idUser,
          Notifikasi(
            uid: anak.idUser,
            judul: 'Jadwal Imunisasi Diperbarui',
            pesan: 'Imunisasi ${item.master.namaVaksin} untuk ${anak.namaAnak} sudah dicatat sebagai selesai.',
            kategori: 'jadwal',
            waktu: DateTime.now(),
          ),
        );
        if (vaksinDariKlinik) {
          await _kurangiStok(vaksinController, item.master.namaVaksin);
        }
        break;
      case 'dilewati':
        await ActivityLogService.log(
          '${item.master.namaVaksin} (Dosis ${item.master.urutanDosis}) untuk ${anak.namaAnak} ditandai TIDAK PERLU DIKEJAR',
          kategori: 'imunisasi',
        );
        await NotifikasiService().createForUser(
          anak.idUser,
          Notifikasi(
            uid: anak.idUser,
            judul: 'Jadwal Imunisasi Diperbarui',
            pesan: 'Jadwal ${item.master.namaVaksin} untuk ${anak.namaAnak} ditandai tidak perlu dikejar.',
            kategori: 'jadwal',
            waktu: DateTime.now(),
          ),
        );
        break;
      case 'tidak bisa dikejar':
        await ActivityLogService.log(
          '${item.master.namaVaksin} (Dosis ${item.master.urutanDosis}) untuk ${anak.namaAnak} ditandai TIDAK BISA DIKEJAR (lewat batas usia)',
          kategori: 'imunisasi',
        );
        await NotifikasiService().createForUser(
          anak.idUser,
          Notifikasi(
            uid: anak.idUser,
            judul: 'Jadwal Imunisasi Diperbarui',
            pesan: 'Jadwal ${item.master.namaVaksin} untuk ${anak.namaAnak} tidak dapat dikejar karena waktu telah lewat.',
            kategori: 'jadwal',
            waktu: DateTime.now(),
          ),
        );
        break;
    }

    return true;
  }

  /// Jadwal ulang manual (kasus pengejaran dosis yang ketinggalan).
  /// Tanggal yang dipilih dokter disimpan sebagai override -- menggantikan
  /// hitungan otomatis berbasis usia untuk baris ini.
  static Future<bool> jadwalUlangManual({
    required JadwalController jadwalController,
    required Anak anak,
    required JadwalTerjadwal item,
    required DateTime tanggalBaru,
  }) async {
    bool success;

    if (item.realisasi != null) {
      final updated = JadwalImunisasi(
        id: item.realisasi!.id,
        idAnak: item.realisasi!.idAnak,
        idVaksin: item.realisasi!.idVaksin,
        tanggalImunisasi: item.realisasi!.tanggalImunisasi,
        status: item.realisasi!.status == 'sudah imunisasi' ? 'belum imunisasi' : item.realisasi!.status,
        namaAnak: item.realisasi!.namaAnak,
        namaVaksin: item.realisasi!.namaVaksin,
        urutanDosis: item.realisasi!.urutanDosis,
        tanggalRencanaOverride: tanggalBaru,
      );
      success = await jadwalController.updateData(item.realisasi!.id!, updated);
    } else {
      final baru = JadwalImunisasi(
        idAnak: anak.id!,
        idVaksin: '',
        tanggalImunisasi: DateTime.now(),
        status: 'belum imunisasi',
        namaAnak: anak.namaAnak,
        namaVaksin: item.master.namaVaksin,
        urutanDosis: item.master.urutanDosis,
        tanggalRencanaOverride: tanggalBaru,
      );
      success = await jadwalController.create(baru);
    }

    if (success) {
      await ActivityLogService.log(
        'Jadwal pengejaran ${item.master.namaVaksin} (Dosis ${item.master.urutanDosis}) untuk ${anak.namaAnak} diubah ke ${formatTanggal(tanggalBaru)}',
        kategori: 'imunisasi',
      );
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
