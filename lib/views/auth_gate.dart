import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/pengguna_model.dart';
import 'login/login_page.dart';
import 'admin/admin_shell_page.dart';
import 'user/user_shell_page.dart';

/// Menentukan halaman pertama yang tampil berdasarkan sesi Firebase Auth
/// yang sedang aktif. Kalau belum login -> LoginPage. Kalau sudah login,
/// ambil role dari tb_pengguna lalu arahkan ke dashboard yang sesuai.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginPage();
        }

        return FutureBuilder<Pengguna?>(
          future: FirestoreService<Pengguna>(
            collectionPath: 'tb_pengguna',
            fromJson: Pengguna.fromJson,
            toJson: (p) => p.toJson(),
          ).getById(user.uid),
          builder: (context, penggunaSnapshot) {
            if (penggunaSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final pengguna = penggunaSnapshot.data;
            if (pengguna == null) {
              // Data profil tidak ditemukan, paksa login ulang.
              return LoginPage();
            }

            return pengguna.role == 'admin'
                ? const AdminShellPage()
                : const UserShellPage();
          },
        );
      },
    );
  }
}
