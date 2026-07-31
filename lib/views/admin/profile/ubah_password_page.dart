import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _obscureLama = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _passwordLamaController,
                obscureText: _obscureLama,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureLama ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureLama = !_obscureLama),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordBaruController,
                obscureText: _obscureBaru,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureBaru ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureBaru = !_obscureBaru),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _konfirmasiController,
                obscureText: _obscureKonfirmasi,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal, width: 2)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKonfirmasi ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                  ),
                ),
                validator: (v) => (v != _passwordBaruController.text) ? 'Password tidak sama' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16)),
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

    setState(() => _isLoading = true);
    try {
      await AuthService().changePassword(
        passwordLama: _passwordLamaController.text,
        passwordBaru: _passwordBaruController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
