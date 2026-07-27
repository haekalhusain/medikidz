import 'package:get/get.dart';
import '../models/jadwal_model.dart';
import '../services/firestore_service.dart';

class JadwalController extends GetxController {
  final _service = FirestoreService<JadwalImunisasi>(
    collectionPath: 'tb_jadwalImunisasi',
    fromJson: JadwalImunisasi.fromJson,
    toJson: (j) => j.toJson(),
  );

  var jadwalList = <JadwalImunisasi>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll(orderBy: 'tanggal_imunisasi').listen((data) {
      jadwalList.assignAll(data);
    });
  }

  Future<bool> create(JadwalImunisasi jadwal) async {
    try {
      isLoading.value = true;
      await _service.create(jadwal);
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateData(String id, JadwalImunisasi jadwal) async {
    try {
      isLoading.value = true;
      await _service.update(id, jadwal);
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Konfirmasi cepat: tandai jadwal sebagai "sudah imunisasi" tanpa perlu
  /// buka form edit penuh — dipakai di alur "Konfirmasi Pasien Telah Diimunisasi".
  Future<bool> konfirmasiSelesai(JadwalImunisasi jadwal) async {
    final updated = JadwalImunisasi(
      id: jadwal.id,
      idAnak: jadwal.idAnak,
      idVaksin: jadwal.idVaksin,
      tanggalImunisasi: jadwal.tanggalImunisasi,
      status: 'sudah imunisasi',
      namaAnak: jadwal.namaAnak,
      namaVaksin: jadwal.namaVaksin,
      urutanDosis: jadwal.urutanDosis,
    );
    return updateData(jadwal.id!, updated);
  }

  Future<void> delete(String id) async {
    try {
      await _service.delete(id);
      Get.snackbar('Berhasil', 'Jadwal dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    }
  }
}
