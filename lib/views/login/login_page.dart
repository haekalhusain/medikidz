import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import '../register/register_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 24),
                const Text('Masuk ke Akun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Akses layanan kesehatan Anda dengan mudah.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                const Text('No. Telp'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama..',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Nomor HP tidak valid' : null,
                ),
                const SizedBox(height: 16),
                const Text('Kata Sandi'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan kata sandi..',
                    border: const OutlineInputBorder(),
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: alur lupa password (reset via Firebase Auth)
                    },
                    child: const Text('Lupa Password?'),
                  ),
                ),
                Obx(() {
                  if (controller.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 8),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : _submit,
                        child: controller.isLoading.value
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Login'),
                      ),
                    )),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    ),
                    child: const Text('Belum punya akun? Daftar di sini'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.controller.login(
      noHp: _noHpController.text.trim(),
      password: _passwordController.text,
    );
  }
}
