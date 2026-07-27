import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'vaksin/vaksin_list_page.dart';
import 'artikel/artikel_list_page.dart';
import 'profile/profile_page.dart';

/// Wrapper dengan bottom navigation bar (Home / Vaksin / Artikel / Profile)
/// sesuai desain. Ini yang dipanggil sebagai halaman utama setelah admin
/// login — GANTI pemanggilan AdminDashboardPage lama (kalau ada) jadi
/// AdminShellPage ini di role_selection_page.dart / auth_gate.dart.
class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _currentIndex = 0;

  final _pages = const [
    AdminDashboardHome(),
    VaksinListPage(),
    ArtikelListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.vaccines_outlined), activeIcon: Icon(Icons.vaccines), label: 'Vaksin'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
