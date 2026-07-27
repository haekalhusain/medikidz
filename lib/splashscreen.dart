import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/auth_gate.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animasi Opacity Logo Ikon (logo.png)
  late Animation<double> _logoOpacityAnimation;

  // Animasi Scale / Ukuran Logo Ikon (logo.png)
  late Animation<double> _logoScaleAnimation;

  // Animasi Opacity Teks (logo2.png)
  late Animation<double> _textOpacityAnimation;

  // Animasi transisi warna background
  late Animation<double> _bgTransitionAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // 1. Durasi 0.0 - 0.2: Layar Putih Polos

    // 2. Durasi 0.2 - 0.5: Logo ikon muncul (Fade in)
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );

    // 3. Durasi 0.5 - 1.0: Logo membesar, background gradasi aktif, & logo2.png (teks) fade in
    _logoScaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    _bgTransitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Navigasi setelah animasi selesai (ditambahkan pengecekan mounted)
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Get.off(() => const AuthGate());
        } else {
          Get.off(() => const OnboardingScreen());
        }
      }
    });

    // Jalankan animasi
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // ----------------------------------------------------
              // Layer 1: Background Putih Polos
              // ----------------------------------------------------
              Container(color: Colors.white),

              // ----------------------------------------------------
              // Layer 2: Background Gradasi Hijau
              // ----------------------------------------------------
              Opacity(
                opacity: _bgTransitionAnimation.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF81C784),
                        Color(0xFFE8F5E9),
                        Color(0xFFA5D6A7),
                        Color(0xFF4DB6AC),
                      ],
                      stops: [0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // ----------------------------------------------------
              // Layer 3: Logo (logo.png) & Teks (logo2.png)
              // ----------------------------------------------------
              Center(
                child: Opacity(
                  opacity: _logoOpacityAnimation.value,
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo Ikon
                        Image.asset(
                          'assets/logo.png',
                          width: 140,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        // Logo Teks (logo2.png)
                        Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Image.asset(
                            'assets/logo2.png',
                            width: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}