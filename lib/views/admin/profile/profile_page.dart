import 'package:flutter/material.dart';
import '../../../models/pengguna_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../auth_gate.dart';
import 'akun_saya_page.dart';
import 'ubah_password_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;
    final penggunaService = FirestoreService<Pengguna>(
      collectionPath: 'tb_pengguna',
      fromJson: Pengguna.fromJson,
      toJson: (p) => p.toJson(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Profil Anda',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Pengguna?>(
        future: uid == null ? null : penggunaService.getById(uid),
        builder: (context, snapshot) {
          final pengguna = snapshot.data;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // --- HERO SECTION WITH GRADIENT ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20, bottom: 32, left: 16, right: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7DCDBC), // Soft Teal Mint
                      Color(0xFFB4E4D8), 
                      Color(0xFFE2F4EE), 
                      Color(0xFFF7FCFA), // Soft Light Cream White
                    ],
                    stops: [0.0, 0.35, 0.7, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF0F5744),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 64,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama User
                    Text(
                      pengguna?.nama ?? '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email User
                    if (pengguna?.email != null && pengguna!.email!.isNotEmpty)
                      Text(
                        pengguna.email!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),

                    // No HP (Logika persis seperti kode asli kamu)
                    Text(
                      pengguna?.noHp ?? '-',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- MENU LIST ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Akun Saya',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AkunSayaPage()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuTile(
                      icon: Icons.vpn_key_outlined,
                      label: 'Ubah Kata Sandi',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UbahPasswordPage()),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ProfileMenuTile(
                      icon: Icons.logout_rounded,
                      label: 'Keluar',
                      color: const Color(0xFFDC2626), // Modern Red
                      isLogout: true,
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar Akun',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Yakin mau keluar dari akun ini?',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isLogout;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? const Color(0xFF1E293B);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: itemColor,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 14,
                    fontWeight: isLogout ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
              if (!isLogout)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF1E293B),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}