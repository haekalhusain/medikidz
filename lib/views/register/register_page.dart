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
      appBar: AppBar(title: const Text('Buat Akun')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
    );
  }

  Widget _buildDone(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: StepDone()),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Get.offAll(() => LoginPage()),
            child: const Text('Masuk Sekarang'),
          ),
        ),
      ],
    );
  }
}
