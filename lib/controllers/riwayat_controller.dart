import 'package:get/get.dart';
import '../models/riwayat_model.dart';
import '../services/firestore_service.dart';

class RiwayatController extends GetxController {
  final _service = FirestoreService<RiwayatImunisasi>(
    collectionPath: 'tb_riwayatImunisasi',
    fromJson: RiwayatImunisasi.fromJson,
    toJson: (r) => r.toJson(),
  );

  var riwayatList = <RiwayatImunisasi>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll(orderBy: 'tanggal_imunisasi', descending: true).listen((data) {
      riwayatList.assignAll(data.where((r) => !r.isDeleted).toList());
    });
  }

  Future<bool> create(RiwayatImunisasi riwayat) async {
    try {
      isLoading.value = true;
      await _service.create(riwayat);
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateData(String id, RiwayatImunisasi riwayat) async {
    try {
      isLoading.value = true;
      await _service.update(id, riwayat);
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
      Get.snackbar('Berhasil', 'Riwayat imunisasi dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    }
  }
}
