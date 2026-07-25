import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/auth_gate.dart';
// import 'firebase_options.dart'; // generate dengan `flutterfire configure`

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MedikidzApp());
}

class MedikidzApp extends StatelessWidget {
  const MedikidzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medikidz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
