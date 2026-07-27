import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart'; 
import 'firebase_options.dart';
import 'splashscreen.dart'; // Impor file splashscreen Anda

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
      // Set home ke SplashScreen, karena logika pengecekan user sudah diatur di dalam SplashScreen
      home: const SplashScreen(), 
    );
  }
}