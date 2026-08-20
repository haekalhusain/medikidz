import 'package:get/get.dart';
import '../models/anak_model.dart';
import '../services/firestore_service.dart';

class AnakController extends GetxController {
  final _service = FirestoreService<Anak>(
    collectionPath: 'tb_anak',
    fromJson: Anak.fromJson,
    toJson: (a) => a.toJson(),
  );

  var anakList = <Anak>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll(orderBy: 'nama_anak').listen((data) {
      anakList.assignAll(data.where((a) => !a.isDeleted).toList());
    });
  }

  Future<bool> create(Anak anak) async {
    try {
      isLoading.value = true;
      await _service.create(anak);
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateData(String id, Anak anak) async {
    try {
      isLoading.value = true;
      // PENTING: pakai updateFields() dengan field spesifik, BUKAN
      // _service.update(id, anak) yang mengirim toJson() penuh (termasuk
      // 'deleted_at': null). Kalau pakai update() biasa, tiap kali anak
      // yang sudah di-soft-delete diedit, deleted_at ke-reset jadi null
      // (anak "hidup" lagi tanpa sengaja). softDelete()/restore() tetap
      // satu-satunya jalur yang boleh mengubah 'deleted_at'.
      await _service.updateFields(id, {
        'id_user': anak.idUser,
        'nama_anak': anak.namaAnak,
        'tanggal_lahir': anak.tanggalLahir.toIso8601String(),
        'jenis_kelamin': anak.jenisKelamin,
        'nik': anak.nik,
      });
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _service.softDelete(id);
      Get.snackbar('Berhasil', 'Data anak dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    }
  }
}
