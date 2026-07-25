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
}
