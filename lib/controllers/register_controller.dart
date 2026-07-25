import 'package:get/get.dart';
import '../services/register_service.dart';

enum RegisterStep { inputData, otp, done }

class RegisterController extends GetxController {
  final RegisterService _service = RegisterService();

  var currentStep = RegisterStep.inputData.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Data sementara, disimpan di memory saja sampai OTP terverifikasi.
  // Akun BELUM dibuat di Firebase Auth sampai langkah ini lolos.
  String _pendingNamaAnak = '';
  String _pendingNoHp = '';
  String _pendingPassword = '';

  /// Langkah 1: validasi form lalu kirim OTP ke WA.
  Future<void> submitRegistration({
    required String namaAnak,
    required String noHp,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final otpCode = await _service.requestOtp(noHp);

      _pendingNamaAnak = namaAnak;
      _pendingNoHp = noHp;
      _pendingPassword = password;
      currentStep.value = RegisterStep.otp;

      Get.snackbar(
        'Mode Testing',
        'Kode OTP kamu: $otpCode (belum kirim WA beneran)',
        duration: const Duration(seconds: 10),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final otpCode = await _service.resendOtp(_pendingNoHp);
      Get.snackbar(
        'Mode Testing',
        'Kode OTP baru: $otpCode (belum kirim WA beneran)',
        duration: const Duration(seconds: 10),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Langkah 2: verifikasi OTP, baru akun & data disimpan.
  Future<void> completeRegistration(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _service.verifyOtpAndRegister(
        namaAnak: _pendingNamaAnak,
        noHp: _pendingNoHp,
        password: _pendingPassword,
        otp: otp,
      );

      currentStep.value = RegisterStep.done;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
