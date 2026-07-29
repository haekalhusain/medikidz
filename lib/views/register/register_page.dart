import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/register_controller.dart';
import '../login/login_page.dart';
import 'widgets/step_input_data.dart';
import 'widgets/step_otp.dart';
import 'widgets/step_done.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFFA2DFCD), // Hijau mint muda sesuai desain
              Color(0xFFE3F6EE),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header dengan Back Button (Background Bulat Putih)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Bagian Logo (Menggunakan assets/logo.png & assets/logo2.png)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Ikon Utama
                    Image.asset(
                      'assets/logo.png',
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    // Logo Teks "KLINIK & APOTEK MediKidz"
                    Image.asset(
                      'assets/logo2.png',
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // White Card Section (Melengkung di atas)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                      child: Obx(() {
                        switch (controller.currentStep.value) {
                          case RegisterStep.inputData:
                            return StepInputData(controller: controller);
                          case RegisterStep.otp:
                            return StepOtp(controller: controller);
                          case RegisterStep.done:
                            return _buildDone(context);
                        }
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDone(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: StepDone()),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A9D8F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: () => Get.offAll(() => LoginPage()),
            child: const Text('Login Sekarang', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}