import 'package:flutter/material.dart';
import '../../../models/pengguna_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import 'ubah_password_page.dart';

/// Halaman Akun Saya khusus admin. Beda dengan versi user, admin cuma
/// punya Data Personal (nama) -- nggak ada tab Data Anak.
///
/// Password TIDAK ditampilkan literal (Firebase Auth memang tidak bisa
/// membaca kembali password yang tersimpan). Field password di sini cuma
/// jalan pintas visual ke halaman "Ubah Kata Sandi" yang sudah ada.
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data personal disimpan.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Akun Saya'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: Colors.teal,
                  child: const Text(
                    'Data personal',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text('Nama', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const UbahPasswordPage()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const Expanded(child: Text('••••••••')),
                              Icon(Icons.edit_outlined, size: 18, color: Colors.teal.shade700),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          onPressed: _isSaving ? null : _submit,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 16)),
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
