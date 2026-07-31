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
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus(); // Tutup keyboard saat submit

    if (_otpController.text.trim().length < 4) {
      widget.controller.errorMessage.value = 'Masukkan kode OTP yang valid';
      return;
    }
    widget.controller.completeRegistration(_otpController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Icon Header (Tosca)
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F6EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_chat_read_outlined,
              size: 48,
              color: Color(0xFF2A9D8F),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Title & Subtitle
        const Center(
          child: Text(
            'Verifikasi OTP',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Kami telah mengirimkan kode verifikasi\nke nomor WhatsApp yang terdaftar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Input Field OTP
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 12,
            color: Color(0xFF2A9D8F),
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '------',
            hintStyle: const TextStyle(
              color: Color(0xFFB0C0D0),
              letterSpacing: 10,
              fontSize: 22,
            ),
            filled: true,
            fillColor: const Color(0xFFF1F5F9), // Abu-abu muda khas MediKidz
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A9D8F), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Error Message
        Obx(() {
          if (controller.errorMessage.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Tombol Verifikasi
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
                      'Verifikasi',
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

        // Link Kirim Ulang OTP
        Center(
          child: Obx(() {
            final isLoading = controller.isLoading.value;
            return GestureDetector(
              onTap: isLoading ? null : controller.resendOtp,
              child: Text(
                'Kirim ulang kode OTP',
                style: TextStyle(
                  color: isLoading ? Colors.grey : const Color(0xFF2A9D8F),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}