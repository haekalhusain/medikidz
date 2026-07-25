import 'package:get/get.dart';
import '../models/jadwal_master_model.dart';
import '../services/firestore_service.dart';

class JadwalMasterController extends GetxController {
  final _service = FirestoreService<JadwalMaster>(
    collectionPath: 'tb_jadwalMaster',
    fromJson: JadwalMaster.fromJson,
    toJson: (j) => j.toJson(),
  );

  var jadwalMasterList = <JadwalMaster>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll(orderBy: 'usia_hari').listen((data) {
      jadwalMasterList.assignAll(data);
    });
  }

  Future<bool> updateData(String id, JadwalMaster item) async {
    try {
      isLoading.value = true;
      await _service.update(id, item);
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(JadwalMaster item) async {
    try {
      isLoading.value = true;
      await _service.create(item);
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
      await _service.delete(id);
      Get.snackbar('Berhasil', 'Jadwal master dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    }
  }
}
