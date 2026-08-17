import 'package:flutter/material.dart';
import '../../../models/pengguna_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';
import '../../auth_gate.dart';
import '../widgets/user_header.dart';
import 'akun_saya_page.dart';
import 'ubah_password_page.dart';

class ProfilAndaPage extends StatelessWidget {
  const ProfilAndaPage({super.key});

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
      appBar: buildUserTopBar(context, showDivider: false, hideProfileIcon: true),
      body: FutureBuilder<Pengguna?>(
        future: uid == null ? null : penggunaService.getById(uid),
        builder: (context, snapshot) {
          final pengguna = snapshot.data;

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF28A997), Color(0xFFB8E7DE)],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    const SizedBox(height: 18),
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_outline,
                          color: Color(0xFF1F3A57),
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      pengguna?.nama ?? '-',
                      style: const TextStyle(
                        color: Color(0xFF17394D),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pengguna?.noHp ?? '-',
                      style: const TextStyle(
                        color: Color(0xFF1C4F63),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.person_outline,
                      label: 'Akun Saya',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AkunSayaPage()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileMenuTile(
                      icon: Icons.key_outlined,
                      label: 'Ubah Kata Sandi',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UbahPasswordPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProfileMenuTile(
                      icon: Icons.logout,
                      label: 'Keluar',
                      color: Colors.red,
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        contentPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F7F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                children: const [
                  Icon(Icons.logout_rounded, size: 48, color: Color(0xFF00A884)),
                  SizedBox(height: 12),
                  Text(
                    'Konfirmasi Keluar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Text(
                'Apakah Anda yakin ingin keluar dari akun ini? Anda akan diminta untuk login kembali jika ingin menggunakan aplikasi.',
                style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFB7C7D7)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: color ?? Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (color == null)
                const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
