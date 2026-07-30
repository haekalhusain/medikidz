import 'package:flutter/material.dart';
import 'jadwal/jadwal_list_page.dart';
import 'anak/anak_saya_list_page.dart';
import 'artikel/user_artikel_list_page.dart';
import 'hubungi_klinik/hubungi_klinik_page.dart'; // Impor Halaman Baru
import 'profile/profil_anda_page.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuItem('Anak Saya', Icons.child_care, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnakSayaListPage()));
      }),
      _MenuItem('Jadwal Imunisasi', Icons.calendar_month, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JadwalListPage()));
      }),
      _MenuItem('Artikel Edukasi', Icons.article, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserArtikelListPage()));
      }),
      _MenuItem('Hubungi Klinik', Icons.support_agent, () {
        // Navigasi ke Halaman Hubungi Klinik
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HubungiKlinikPage()));
      }),
      _MenuItem('Artikel Favorit', Icons.favorite, () => _comingSoon(context, 'Artikel Favorit')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil Anda',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilAndaPage()),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          return Card(
            child: InkWell(
              onTap: menu.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(menu.icon, size: 36, color: Colors.teal),
                  const SizedBox(height: 8),
                  Text(menu.title, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _comingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name — ikuti pattern modul Jadwal Imunisasi untuk membuat ini.')),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _MenuItem(this.title, this.icon, this.onTap);
}