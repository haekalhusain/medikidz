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
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    UserDashboardHome(),
    UserVaksinListPage(),
    UserArtikelListPage(),
    ProfilAndaPage(),
  ];

  // Data Item Navbar
  final List<_NavItemData> _navItems = const [
    _NavItemData(
      icon: Icons.home_rounded,
      outlinedIcon: Icons.home_outlined,
      label: 'Home',
    ),
    _NavItemData(
      icon: Icons.vaccines_rounded,
      outlinedIcon: Icons.vaccines_outlined,
      label: 'Vaksin',
    ),
    _NavItemData(
      icon: Icons.article_rounded,
      outlinedIcon: Icons.article_outlined,
      label: 'Artikel',
    ),
    _NavItemData(
      icon: Icons.person_rounded,
      outlinedIcon: Icons.person_outlined,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
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
                const activeColor = Color(0xFF2F8D7E); // Warna tema utama Medikidz
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
                              isSelected
                                  ? _navItems[index].icon
                                  : _navItems[index].outlinedIcon,
                              color: isSelected ? activeColor : inactiveColor,
                              size: 26,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _navItems[index].label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected ? activeColor : inactiveColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6), // Spacing bawah proporsional
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
  final IconData outlinedIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
  });
}