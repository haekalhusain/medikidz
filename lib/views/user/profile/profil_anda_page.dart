import 'package:flutter/material.dart';
import '../../../models/pengguna_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';
import '../../auth_gate.dart';
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
      appBar: AppBar(title: const Text('Profil Anda')),
      body: FutureBuilder<Pengguna?>(
        future: uid == null ? null : penggunaService.getById(uid),
        builder: (context, snapshot) {
          final pengguna = snapshot.data;

          return ListView(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal.shade300, Colors.teal.shade50],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.teal, width: 2),
                      ),
                      child: const Icon(Icons.person_outline, size: 48, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pengguna?.nama ?? '-',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (pengguna?.email != null && pengguna!.email!.isNotEmpty)
                      Text(pengguna.email!, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(pengguna?.noHp ?? '-', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.person_outline,
                      label: 'Akun Saya',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AkunSayaPage()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ProfileMenuTile(
                      icon: Icons.key_outlined,
                      label: 'Ubah Kata Sandi',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UbahPasswordPage()),
                      ),
                    ),
                    const SizedBox(height: 12),
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
        title: const Text('Keluar Akun'),
        content: const Text('Yakin mau keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
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
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
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
                  style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
              if (color == null) const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
