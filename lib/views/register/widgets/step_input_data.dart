import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/register_controller.dart';

class StepInputData extends StatefulWidget {
  final RegisterController controller;
  const StepInputData({super.key, required this.controller});

  @override
  State<StepInputData> createState() => _StepInputDataState();
}

class _StepInputDataState extends State<StepInputData> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnakController = TextEditingController();
  final _noHpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _ingatSaya = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          const Text('Nama'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _namaAnakController,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama..',
              border: OutlineInputBorder(),
              filled: true,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama anak wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          const Text('No. Telp'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _noHpController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Masukkan No. Telp..',
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
            validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
          ),
          const SizedBox(height: 16),
          const Text('Konfirmasi Kata Sandi'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Masukkan ulang kata sandi..',
              border: const OutlineInputBorder(),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Wajib diisi';
              if (v != _passwordController.text) return 'Kata sandi tidak sama';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(value: _ingatSaya, onChanged: (v) => setState(() => _ingatSaya = v ?? false)),
              const Text('Ingat Saya'),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _submit,
                  child: controller.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Register'),
                ),
              )),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.controller.submitRegistration(
      namaAnak: _namaAnakController.text.trim(),
      noHp: _noHpController.text.trim(),
      password: _passwordController.text,
    );
  }
}
