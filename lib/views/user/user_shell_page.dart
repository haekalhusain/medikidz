import 'package:flutter/material.dart';
import 'user_dashboard_home.dart';
import 'vaksin/user_vaksin_list_page.dart';
import 'artikel/user_artikel_list_page.dart';
import 'profile/profil_anda_page.dart';

class UserShellPage extends StatefulWidget {
  const UserShellPage({super.key});

  @override
  State<UserShellPage> createState() => _UserShellPageState();
}

class _UserShellPageState extends State<UserShellPage> {
  int _index = 0;

  final _pages = const [
    UserDashboardHome(),
    UserVaksinListPage(),
    UserArtikelListPage(),
    ProfilAndaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.vaccines_outlined), activeIcon: Icon(Icons.vaccines), label: 'Vaksin'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
