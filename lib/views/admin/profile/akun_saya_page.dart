/// Halaman Akun Saya khusus admin. Beda dengan versi user, admin cuma
/// punya Data Personal (nama) -- nggak ada tab Data Anak.
///
/// Password TIDAK ditampilkan literal (Firebase Auth memang tidak bisa
/// membaca kembali password yang tersimpan). Field password di sini cuma
/// jalan pintas visual ke halaman "Ubah Kata Sandi" yang sudah ada.
import 'package:flutter/material.dart';
import '../../../models/pengguna_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import 'ubah_password_page.dart';

/// Halaman Akun Saya khusus admin.
class AkunSayaPage extends StatefulWidget {
  const AkunSayaPage({super.key});

  @override
  State<AkunSayaPage> createState() => _AkunSayaPageState();
}

class _AkunSayaPageState extends State<AkunSayaPage> {
  final _namaController = TextEditingController();
  final _penggunaService = FirestoreService<Pengguna>(
    collectionPath: 'tb_pengguna',
    fromJson: Pengguna.fromJson,
    toJson: (p) => p.toJson(),
  );

  bool _isLoading = true;
  bool _isSaving = false;
  String? _uid;
  Pengguna? _pengguna;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _uid = AuthService().currentUser?.uid;
    if (_uid != null) {
      _pengguna = await _penggunaService.getById(_uid!);
      _namaController.text = _pengguna?.nama ?? '';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    if (_uid == null) return;
    setState(() => _isSaving = true);

    final updated = Pengguna(
      id: _uid,
      nama: _namaController.text.trim(),
      noHp: _pengguna?.noHp ?? '',
      role: _pengguna?.role ?? 'admin',
      email: _pengguna?.email,
      alamat: _pengguna?.alamat,
    );

    try {
      await _penggunaService.update(_uid!, updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data personal berhasil disimpan.'),
            backgroundColor: Color(0xFF2D9580),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300, width: 0.8),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),
        title: const Text(
          'Akun Saya',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D9580)),
            )
          : Column(
              children: [
                // --- SUB HEADER "Data personal" ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF359D89), // Deep Mint Teal
                  ),
                  child: const Text(
                    'Data personal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // --- FORM BODY ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    children: [
                      // Field Label: Nama
                      const Text(
                        'Nama',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _namaController,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          hintText: 'Masukkan nama',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(color: Color(0xFF359D89), width: 1.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Field Label: Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(28),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UbahPasswordPage(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    '••••••••',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.teal.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // --- TOMBOL SELESAI ---
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF359D89),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: _isSaving ? null : _submit,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Selesai',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
