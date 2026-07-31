import 'package:get/get.dart';
import '../models/pengguna_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

/// Stream semua akun dengan role 'user' (pasien/orang tua), dipakai buat
/// dropdown "Pilih Akun Orang Tua" saat admin menambahkan data anak.
class PenggunaController extends GetxController {
  final _service = FirestoreService<Pengguna>(
    collectionPath: 'tb_pengguna',
    fromJson: Pengguna.fromJson,
    toJson: (p) => p.toJson(),
  );

  var penggunaList = <Pengguna>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service.streamAll(orderBy: 'nama').listen((data) {
      penggunaList.assignAll(data.where((p) => p.role == 'user').toList());
    });
  }

  /// Ambil profil akun yang SEDANG LOGIN (admin ataupun user), dipakai
  /// buat auto-isi field "Penulis" saat admin membuat artikel baru.
  /// Doc ID di tb_pengguna sama persis dengan UID Firebase Auth.
  Future<Pengguna?> getCurrentPengguna() async {
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return null;
    return _service.getById(uid);
  }
}
