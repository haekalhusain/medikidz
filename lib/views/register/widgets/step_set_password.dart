import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/register_controller.dart';

class StepSetPassword extends StatefulWidget {
  final RegisterController controller;
  const StepSetPassword({super.key, required this.controller});

  @override
  State<StepSetPassword> createState() => _StepSetPasswordState();
}

class _StepSetPasswordState extends State<StepSetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buat password untuk akun Anda.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Konfirmasi Password', border: OutlineInputBorder()),
            validator: (v) => (v != _passwordController.text) ? 'Password tidak sama' : null,
          ),
          const SizedBox(height: 24),
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
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _submit,
                  child: controller.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Buat Akun'),
                ),
              )),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.controller.completeRegistration(_passwordController.text);
  }
}
