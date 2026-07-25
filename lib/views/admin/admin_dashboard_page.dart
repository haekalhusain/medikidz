import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'vaksin/vaksin_list_page.dart';
import 'anak/anak_list_page.dart';
import 'anak/cari_akun_page.dart';
import 'jadwal_master/jadwal_master_list_page.dart';
import '../../controllers/anak_controller.dart';
import '../../controllers/jadwal_master_controller.dart';
import '../../controllers/jadwal_controller.dart';
import '../../controllers/vaksin_controller.dart';
import '../../services/jadwal_schedule_service.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuItem('Kelola Vaksin', Icons.vaccines, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VaksinListPage()));
      }),
      _MenuItem('Data Anak', Icons.child_care, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnakListPage()));
      }),
      _MenuItem('Tambah Anak (akun ada)', Icons.person_add, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CariAkunPage()));
      }),
      _MenuItem('Jadwal Master', Icons.medical_information, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JadwalMasterListPage()));
      }),
      _MenuItem('Kelola Pengguna', Icons.people, () => _comingSoon(context, 'Pengguna')),
      _MenuItem('Artikel Edukasi', Icons.article, () => _comingSoon(context, 'Artikel Edukasi')),
      _MenuItem('Jadwal & Riwayat', Icons.calendar_month, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnakListPage()));
      }),
    ];

    // Controller ini juga dipakai halaman lain, GetX otomatis reuse instance-nya.
    final anakController = Get.put(AnakController());
    final masterController = Get.put(JadwalMasterController());
    final jadwalController = Get.put(JadwalController());
    final vaksinController = Get.put(VaksinController());
    final scheduleService = JadwalScheduleService();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() {
            final vaksinBulanIni = scheduleService.countJadwalBulanIni(
              anakList: anakController.anakList,
              masterList: masterController.jadwalMasterList,
              semuaJadwalImunisasi: jadwalController.jadwalList,
              bulan: DateTime.now(),
            );
            final stokMenipis = vaksinController.vaksinList
                .where((v) => v.statusStok == 'menipis' || v.statusStok == 'habis')
                .length;

            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event_available,
                    color: Colors.blue,
                    value: '$vaksinBulanIni',
                    label: 'Dosis diperlukan\nbulan ini',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const AnakListPage())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.warning_amber_rounded,
                    color: stokMenipis > 0 ? Colors.red : Colors.green,
                    value: '$stokMenipis',
                    label: 'Stok vaksin\nmenipis/habis',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const VaksinListPage())),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name — ikuti pattern modul Vaksin/Anak untuk membuat ini.')),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                    Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _MenuItem(this.title, this.icon, this.onTap);
}
