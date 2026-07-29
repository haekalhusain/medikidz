import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'vaksin/vaksin_list_page.dart';
import 'artikel/artikel_list_page.dart';
import 'profile/profile_page.dart';

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

  // Data Item Navbar
  final List<_NavItemData> _navItems = const [
    _NavItemData(icon: Icons.home_rounded, label: 'Home'),
    _NavItemData(icon: Icons.vaccines_rounded, label: 'Vaksin'),
    _NavItemData(icon: Icons.article_rounded, label: 'Artikel'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Memastikan latar belakang body berada di bawah navbar jika transparan
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = _currentIndex == index;
                final activeColor = const Color(0xFF2E9E86); // Warna hijau sesuai gambar
                final inactiveColor = Colors.grey.shade600;

                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = index),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Indicator Line di bagian atas
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 4,
                          width: isSelected ? 32 : 0,
                          decoration: BoxDecoration(
                            color: isSelected ? activeColor : Colors.transparent,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(4),
                            ),
                          ),
                        ),
                        
                        // Icon dan Label
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _navItems[index].icon,
                              color: isSelected ? activeColor : inactiveColor,
                              size: 26,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _navItems[index].label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? activeColor : inactiveColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6), // Spacing bawah agar proporsional
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.label,
  });
}