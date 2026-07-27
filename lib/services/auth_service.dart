import 'package:firebase_auth/firebase_auth.dart';

/// Auth service sungguhan pakai Firebase Auth.
/// Firebase Auth butuh format email, jadi No. Telp dikonversi jadi
/// "pseudo-email" (mis. 081234567890 -> 081234567890@medikidz.app).
/// Password TIDAK pernah disimpan manual di Firestore — semua hashing
/// & validasi ditangani oleh Firebase Auth.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _emailDomain = 'medikidz.app';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String _normalizeNoHp(String noHp) {
    var digits = noHp.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }

  String _toPseudoEmail(String noHp) => '${_normalizeNoHp(noHp)}@$_emailDomain';

  /// Daftar akun baru. Mengembalikan uid user yang baru dibuat.
  Future<String> register({required String noHp, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _toPseudoEmail(noHp),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw AuthException('Gagal membuat akun. Silakan coba lagi.');
      }
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  /// Login dengan No. Telp + password. Mengembalikan uid user.
  Future<String> login({required String noHp, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _toPseudoEmail(noHp),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw AuthException('Gagal masuk. Silakan coba lagi.');
      }
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  Future<void> logout() => _auth.signOut();

  /// Ubah password. Firebase Auth mewajibkan re-autentikasi dulu pakai
  /// password LAMA sebelum boleh set password baru — ini alasan kenapa
  /// form Ubah Password butuh field "Password Lama", bukan cuma password baru.
  Future<void> changePassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw AuthException('Sesi login tidak ditemukan. Silakan masuk ulang.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordLama,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(passwordBaru);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapError(e));
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Nomor HP ini sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah, minimal 6 karakter.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'No. Telp atau kata sandi salah.';
      case 'invalid-email':
        return 'Nomor HP tidak valid.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'requires-recent-login':
        return 'Sesi login sudah lama, silakan masuk ulang lalu coba lagi.';
      default:
        return e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
