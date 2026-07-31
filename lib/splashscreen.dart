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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _holeScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Diubah menjadi 3 detik pas
    );

    // 1. Animasi Lubang Elips (Membesar lalu Mengecil/Hilang)
    _holeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_controller);

    // 2. Animasi Logo Slide Up (Dinaikkan dari posisi lubang di bawah ke posisi tengah)
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.8), // Posisi awal jauh di bawah (pas di area lubang)
      end: Offset.zero,             // Berhenti tepat di tengah layar
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Logo Membesar dari Kecil ke Ukuran Normal
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // 4. Logo Fade In
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.4, curve: Curves.easeIn),
      ),
    );

    // 5. Teks Logo (logo2.png) Fade In di Akhir
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    // Navigasi ke Halaman Berikutnya
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- LUBANG ELIPS GEPENG (Di Posisi Agak Bawah) ---
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.32, // Mengunci posisi agak ke bawah
              child: AnimatedBuilder(
                animation: _holeScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _holeScaleAnimation.value,
                    child: Container(
                      width: 150,
                      height: 18, // Rasio tinggi-lebar yang membuat elips sangat gepeng
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.55),
                        borderRadius: const BorderRadius.all(Radius.elliptical(150, 18)),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- LOGO & TEKS (Posisi Tepat di Tengah Layar) ---
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Animasi
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _logoSlideAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Image.asset(
                              'assets/logo.png',
                              width: 130,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Teks Logo
                  AnimatedBuilder(
                    animation: _textOpacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: Image.asset(
                          'assets/logo2.png',
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}