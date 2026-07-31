import 'package:get/get.dart';
import '../models/artikel_model.dart';
import '../services/firestore_service.dart';
import '../services/activity_log_service.dart';

class ArtikelController extends GetxController {
  final _service = FirestoreService<Artikel>(
    collectionPath: 'tb_artikelEdukasi',
    fromJson: Artikel.fromJson,
    toJson: (a) => a.toJson(),
  );

  var artikelList = <Artikel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll(orderBy: 'tanggal_upload', descending: true).listen((data) {
      artikelList.assignAll(data);
    });
  }

  Future<void> fetchArtikel() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Artikel artikel) async {
    try {
      isLoading.value = true;
      await _service.create(artikel);
      await ActivityLogService.log(
        'Menambahkan artikel baru: ${artikel.judul}',
        kategori: 'artikel',
      );
      return true;
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateData(String id, Artikel artikel) async {
    try {
      isLoading.value = true;
      await _service.update(id, artikel);
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
      Get.snackbar('Berhasil', 'Artikel dihapus.');
    } catch (e) {
      Get.snackbar('Gagal', e.toString());
    }
  }
}