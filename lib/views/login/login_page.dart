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
  void dispose() {
    _noHpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    // Deteksi apakah keyboard sedang aktif/terbuka
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3E5FC),
              Color(0xFFE8F5E9),
              Color(0xFF81C784),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- HEADER (Tombol Back) ---
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

              // --- LOGO & BRANDING ---
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo 1 (Ikon Medikidz) - Dinaikkan ukurannya sedikit
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: isKeyboardOpen ? 110 : 160, // sebelumnya 70 : 120
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Menampilkan Logo 2 (Teks Medikidz) hanya jika keyboard TIDAK terbuka
                        if (!isKeyboardOpen) ...[
                          const AnimatedSizedBox(
                            duration: Duration(milliseconds: 250),
                            height: 6,
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: 170,
                            child: Image.asset(
                              'assets/logo2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // --- FORM CONTAINER (Background Putih) ---
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -4),
                    )
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      isKeyboardOpen ? 16 : 28,
                      24,
                      isKeyboardOpen ? 16 : 28,
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Masuk ke Akun',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Center(
                              child: Text(
                                'Akses layanan kesehatan Anda dengan mudah.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            AnimatedSizedBox(
                              duration: const Duration(milliseconds: 250),
                              height: isKeyboardOpen ? 10 : 20,
                            ),

                            // Input No. Telp
                            const Text(
                              'No. Telp',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _noHpController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Masukkan no. hp..',
                                hintStyle: const TextStyle(
                                    color: Colors.black38, fontSize: 13),
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                errorStyle: const TextStyle(
                                  fontSize: 11,
                                  height: 0.9,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().length < 10)
                                      ? 'Nomor HP tidak valid'
                                      : null,
                            ),
                            AnimatedSizedBox(
                              duration: const Duration(milliseconds: 250),
                              height: isKeyboardOpen ? 6 : 14,
                            ),

                            // Input Kata Sandi
                            const Text(
                              'Kata Sandi',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Masukkan kata sandi..',
                                hintStyle: const TextStyle(
                                    color: Colors.black38, fontSize: 13),
                                filled: true,
                                fillColor: const Color(0xFFF1F5F9),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                errorStyle: const TextStyle(
                                  fontSize: 11,
                                  height: 0.9,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black45,
                                    size: 18,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Kata sandi wajib diisi'
                                  : null,
                            ),

                            // Lupa Password Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Alur Lupa Password
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: Color(0xFF2E9E86),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedSizedBox(
                              duration: const Duration(milliseconds: 250),
                              height: isKeyboardOpen ? 6 : 12,
                            ),

                            // Error Message Display (GetX)
                            Obx(() {
                              if (controller.errorMessage.isNotEmpty) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),

                            // Tombol Login
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF2E9E86),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            AnimatedSizedBox(
                              duration: const Duration(milliseconds: 250),
                              height: isKeyboardOpen ? 10 : 18,
                            ),

                            // Link Registrasi
                            Center(
                              child: GestureDetector(
                                onTap: () => Get.to(() => RegisterPage()),
                                child: RichText(
                                  text: const TextSpan(
                                    text: 'Belum punya akun? ',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Daftar di sini',
                                        style: TextStyle(
                                          color: Color(0xFF2E9E86),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.controller.login(
      noHp: _noHpController.text.trim(),
      password: _passwordController.text,
    );
  }
}

class AnimatedSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Duration duration;
  final Curve curve;

  const AnimatedSizedBox({
    super.key,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      width: width,
      height: height,
    );
  }
}