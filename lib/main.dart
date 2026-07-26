import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'views/auth_gate.dart'; 
import 'firebase_options.dart';
import 'onboarding_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MedikidzApp());
}

class MedikidzApp extends StatelessWidget {
  const MedikidzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Medikidz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: FirebaseAuth.instance.currentUser != null 
          ? const AuthGate() // Jika sudah login, langsung ke AuthGate (akan diarahkan ke Home/Admin otomatis)
          : const OnboardingScreen(), // Jika belum login, tampilkan Onboarding
    );
  }
}