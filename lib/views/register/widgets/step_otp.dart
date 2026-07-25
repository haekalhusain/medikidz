import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/register_controller.dart';

class StepOtp extends StatefulWidget {
  final RegisterController controller;
  const StepOtp({super.key, required this.controller});

  @override
  State<StepOtp> createState() => _StepOtpState();
}

class _StepOtpState extends State<StepOtp> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListView(
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.sms_outlined, size: 56, color: Colors.teal),
        const SizedBox(height: 16),
        const Text(
          'Verifikasi Nomor WhatsApp',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Kami sudah mengirim kode OTP ke nomor WhatsApp yang kamu daftarkan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(fontSize: 22, letterSpacing: 8),
          decoration: const InputDecoration(
            counterText: '',
            hintText: '------',
            border: OutlineInputBorder(),
          ),
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
                    : const Text('Verifikasi'),
              ),
            )),
        const SizedBox(height: 12),
        Center(
          child: Obx(() => TextButton(
                onPressed: controller.isLoading.value ? null : controller.resendOtp,
                child: const Text('Kirim ulang kode OTP'),
              )),
        ),
      ],
    );
  }

  void _submit() {
    if (_otpController.text.trim().length < 4) {
      widget.controller.errorMessage.value = 'Masukkan kode OTP yang valid';
      return;
    }
    widget.controller.completeRegistration(_otpController.text.trim());
  }
}
