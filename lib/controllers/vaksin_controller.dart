import 'package:get/get.dart';
import '../models/vaksin_model.dart';
import '../services/firestore_service.dart';

class VaksinController extends GetxController {
  final _service = FirestoreService<Vaksin>(
    collectionPath: 'tb_vaksin',
    fromJson: Vaksin.fromJson,
    toJson: (v) => v.toJson(),
  );

  var vaksinList = <Vaksin>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll(orderBy: 'nama_vaksin').listen((data) {
      vaksinList.assignAll(data);
    });
  }

  Future<bool> create(Vaksin vaksin) async {
    try {
      isLoading.value = true;
      await _service.create(vaksin);
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateData(String id, Vaksin vaksin) async {
    try {
      isLoading.value = true;
      await _service.update(id, vaksin);
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
      Get.snackbar('Berhasil', 'Vaksin dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    }
  }
}
