import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/pengguna_model.dart';
import '../views/admin/admin_dashboard_page.dart';
import '../views/user/user_dashboard_page.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final FirestoreService<Pengguna> _penggunaService = FirestoreService<Pengguna>(
    collectionPath: 'tb_pengguna',
    fromJson: Pengguna.fromJson,
    toJson: (p) => p.toJson(),
  );

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> login({required String noHp, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uid = await _authService.login(noHp: noHp, password: password);
      final pengguna = await _penggunaService.getById(uid);

      if (pengguna == null) {
        errorMessage.value = 'Data akun tidak ditemukan. Hubungi admin.';
        return;
      }

      if (pengguna.role == 'admin') {
        Get.offAll(() => const AdminDashboardPage());
      } else {
        Get.offAll(() => const UserDashboardPage());
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
