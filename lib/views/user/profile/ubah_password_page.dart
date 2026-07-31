import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Kata Sandi')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _passwordBaruController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi Baru', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _konfirmasiController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Konfirmasi Kata Sandi Baru', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (v != _passwordBaruController.text) return 'Kata sandi tidak sama';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(_passwordBaruController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah.')));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.code == 'requires-recent-login'
            ? 'Demi keamanan, silakan logout dan login ulang sebelum mengubah kata sandi.'
            : (e.message ?? 'Gagal mengubah kata sandi.');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
