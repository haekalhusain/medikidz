import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'views/auth_gate.dart'; // <--- IMPORT AUTH GATE DI SINI

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Sehat Bersama Medikidz",
      "desc": "Layanan kesehatan anak yang mudah, cepat, dan terpercaya untuk keluarga Anda",
      "image": "assets/onboarding1.svg"
    },
    {
      "title": "Konsultasi Lebih Mudah",
      "desc": "Buat janji dengan dokter anak tanpa perlu antre langsung di klinik",
      "image": "assets/onboarding2.svg"
    },
    {
      "title": "Semua dalam Satu Aplikasi",
      "desc": "Akses layanan klinik, informasi kesehatan, dan kebutuhan apotek dengan praktis",
      "image": "assets/onboarding3.svg"
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // FUNGSI UNTUK PINDAH KE AUTH GATE
  void _goToAuth() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthGate(), // <--- ARAHKAN KE AUTH GATE
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryTeal = const Color(0xFF269D83);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AREA UTAMA
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. PAGEVIEW GAMBAR & TEKS
                    SizedBox(
                      height: 380,
                      child: PageView.builder(
                        controller: _controller,
                        onPageChanged: (index) => setState(() => _currentIndex = index),
                        itemCount: _onboardingData.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // GAMBAR ILUSTRASI
                              Transform.translate(
                                offset: const Offset(15, 0), 
                                child: SvgPicture.asset(
                                  _onboardingData[index]['image']!,
                                  height: 250,
                                  fit: BoxFit.contain,
                                  placeholderBuilder: (context) => SizedBox(
                                    height: 250,
                                    child: Center(
                                      child: CircularProgressIndicator(color: primaryTeal),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              // JUDUL
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _onboardingData[index]['title']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22, 
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // DESKRIPSI
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  _onboardingData[index]['desc']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14, 
                                    color: Color.fromARGB(255, 109, 109, 109), 
                                    height: 1.4, 
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. INDIKATOR TITIK-TITIK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: 6,
                          width: _currentIndex == index ? 18 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _currentIndex == index ? primaryTeal : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. NAVIGASI BAWAH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOMBOL LEWATI
                  _currentIndex != _onboardingData.length - 1
                      ? TextButton(
                          onPressed: _goToAuth, // Panggil fungsi pindah ke Auth
                          child: const Text(
                            "Lewati",
                            style: TextStyle(
                              color: Color.fromARGB(255, 120, 120, 120), 
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox(width: 60),

                  // TOMBOL BULAT HIJAU (PANAH TERUS)
                  GestureDetector(
                    onTap: () {
                      if (_currentIndex < _onboardingData.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        _goToAuth(); // Panggil fungsi pindah ke Auth jika di slide terakhir
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryTeal, 
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios, 
                        color: Colors.white, 
                        size: 22,
                      ),
                    ),
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