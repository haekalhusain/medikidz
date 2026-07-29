import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/register_controller.dart';
import '../../login/login_page.dart';

class StepInputData extends StatefulWidget {
  final RegisterController controller;
  const StepInputData({super.key, required this.controller});

  @override
  State<StepInputData> createState() => _StepInputDataState();
}

class _StepInputDataState extends State<StepInputData> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _ingatSaya = false;

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus(); // Tutup keyboard saat submit

    // Validasi Form
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    // Panggil fungsi pendaftaran di controller
    widget.controller.submitRegistration(
      namaAnak: _namaController.text.trim(),
      noHp: _noHpController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Title & Subtitle
          const Center(
            child: Text(
              'Buat Akun',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Mulai perjalanan sehat anda bersama kami.\nJadi tunggu apalagi?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 1. Input Nama
          _buildLabel('Nama'),
          TextFormField(
            controller: _namaController,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('Masukkan nama lengkap anda..'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // 2. Input No. Telp
          _buildLabel('No. Telp'),
          TextFormField(
            controller: _noHpController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('Masukkan no. telp..'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'No. Telp wajib diisi';
              if (v.trim().length < 10) return 'Nomor telepon tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // 3. Input Kata Sandi
          _buildLabel('Kata Sandi'),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('Masukkan kata sandi..').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
          ),
          const SizedBox(height: 14),

          // 4. Input Konfirmasi Kata Sandi
          _buildLabel('Konfirmasi Kata Sandi'),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(fontSize: 14),
            decoration: _buildInputDecoration('Masukkan ulang kata sandi..').copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
              if (v != _passwordController.text) return 'Kata sandi tidak sama';
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Checkbox Ingat Saya
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _ingatSaya,
                  activeColor: const Color(0xFF2A9D8F),
                  side: const BorderSide(color: Colors.black45, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                  onChanged: (v) => setState(() => _ingatSaya = v ?? false),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Ingat Saya', style: TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),

          // Pesan Error dari Controller (jika gagal)
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Tombol Register
          Obx(() {
            final isLoading = controller.isLoading.value;
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A9D8F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Footer Text (Sudah punya akun? Masuk di sini)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah punya akun? ',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              GestureDetector(
                onTap: () => Get.offAll(() => LoginPage()),
                child: const Text(
                  'Masuk di sini',
                  style: TextStyle(
                    color: Color(0xFF2A9D8F),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0C0D0), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2A9D8F), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}