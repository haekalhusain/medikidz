import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/register_models.dart';

/// MODE TESTING: OTP disimpan & dicek langsung lewat Firestore, TANPA kirim
/// WA beneran (tidak butuh Cloud Functions / Fonnte / plan Blaze).
/// Kodenya dikembalikan ke caller supaya bisa ditampilkan di layar app.
///
/// GANTI nanti kalau sudah siap produksi: bagian _saveOtp tetap dipakai,
/// tapi tambahkan pemanggilan API Fonnte (lewat Cloud Function) di
/// sendOtp/resendOtp, dan JANGAN kembalikan kode OTP-nya ke UI lagi.
class OtpService {
  final _otpCollection = FirebaseFirestore.instance.collection('tb_otp');

  String _normalizeNoHp(String noHp) {
    var digits = noHp.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }

  /// Mengirim OTP. Return value = kode OTP-nya (HANYA untuk mode testing,
  /// supaya bisa ditampilkan di UI selagi belum ada pengiriman WA beneran).
  Future<String> sendOtp(String noHp) => _saveOtp(noHp);

  Future<String> resendOtp(String noHp) => _saveOtp(noHp);

  Future<String> _saveOtp(String noHp) async {
    final code = (100000 + Random().nextInt(900000)).toString();
    final key = _normalizeNoHp(noHp);

    await _otpCollection.doc(key).set({
      'code': code,
      'expires_at': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    });

    return code;
  }

  /// Mengembalikan true kalau kode OTP valid & belum kedaluwarsa.
  Future<bool> verifyOtp({required String noHp, required String otp}) async {
    final key = _normalizeNoHp(noHp);
    final doc = await _otpCollection.doc(key).get();

    if (!doc.exists) {
      throw RegisterException('Kode OTP tidak ditemukan. Kirim ulang kodenya.');
    }

    final data = doc.data()!;
    final expiresAt = DateTime.parse(data['expires_at']);
    if (DateTime.now().isAfter(expiresAt)) {
      throw RegisterException('Kode OTP sudah kedaluwarsa. Kirim ulang kodenya.');
    }

    if (data['code'] != otp.trim()) {
      throw RegisterException('Kode OTP salah.');
    }

    await _otpCollection.doc(key).delete();
    return true;
  }
}
