import 'auth_service.dart';
import 'fcm_service.dart';
import 'otp_service.dart';
import 'firestore_service.dart';
import '../models/pengguna_model.dart';
import '../models/anak_model.dart';
import '../models/register_models.dart';

/// Orkestrasi proses registrasi:
/// 1. Kirim & verifikasi OTP WA (pastikan No. Telp nyata)
/// 2. Buat akun di Firebase Auth (No. Telp + Kata Sandi)
/// 3. Simpan profil pengguna di tb_pengguna
/// 4. Simpan data anak pertama di tb_anak
class RegisterService {
  final AuthService _authService = AuthService();
  final OtpService _otpService = OtpService();

  final FirestoreService<Pengguna> _penggunaService = FirestoreService<Pengguna>(
    collectionPath: 'tb_pengguna',
    fromJson: Pengguna.fromJson,
    toJson: (p) => p.toJson(),
  );

  final FirestoreService<Anak> _anakService = FirestoreService<Anak>(
    collectionPath: 'tb_anak',
    fromJson: Anak.fromJson,
    toJson: (a) => a.toJson(),
  );

  /// Langkah 1: kirim kode OTP ke WA nomor yang didaftarkan.
  /// Akun BELUM dibuat di sini — cuma verifikasi nomor.
  /// MODE TESTING: mengembalikan kode OTP-nya supaya bisa ditampilkan di UI
  /// (karena belum ada pengiriman WA beneran / Cloud Functions).
  Future<String> requestOtp(String noHp) => _otpService.sendOtp(noHp);

  Future<String> resendOtp(String noHp) => _otpService.resendOtp(noHp);

  /// Langkah 2: verifikasi OTP, kalau valid baru buat akun + data pengguna/anak.
  Future<RegistrationResult> verifyOtpAndRegister({
    required String namaAnak,
    required String noHp,
    required String password,
    required String otp,
  }) async {
    // Verifikasi dulu nomor WA-nya nyata
    await _otpService.verifyOtp(noHp: noHp, otp: otp);

    // Baru buat akun Auth
    final uid = await _authService.register(noHp: noHp, password: password);

    try {
      final pengguna = Pengguna(id: uid, nama: namaAnak, noHp: noHp, role: 'user');
      await _penggunaService.createWithId(uid, pengguna);
      await FcmService().saveTokenForCurrentUser();

      // Tanggal lahir & jenis kelamin memakai nilai sementara karena
      // desain register tidak menyediakan kolom untuk itu — admin
      // klinik melengkapinya lewat menu data anak.
      final anak = Anak(
        idUser: uid,
        namaAnak: namaAnak,
        tanggalLahir: DateTime.now(),
        jenisKelamin: 'laki-laki',
      );
      final idAnak = await _anakService.create(anak);

      return RegistrationResult(idUser: uid, idAnak: idAnak);
    } catch (e) {
      throw RegisterException(
        'Akun berhasil dibuat tapi data gagal disimpan: $e. Silakan hubungi admin.',
      );
    }
  }
}
