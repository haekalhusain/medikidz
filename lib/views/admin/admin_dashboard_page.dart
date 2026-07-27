import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'vaksin/vaksin_list_page.dart';
import 'artikel/artikel_list_page.dart';
import 'anak/anak_list_page.dart';
import 'jadwal/kelola_jadwal_list_page.dart';
import 'riwayat/riwayat_list_page.dart';
import '../../controllers/artikel_controller.dart';
import '../../controllers/anak_controller.dart';
import '../../controllers/jadwal_controller.dart';
import '../../controllers/jadwal_master_controller.dart';
import '../../controllers/vaksin_controller.dart';
import '../../controllers/riwayat_controller.dart';
import '../../services/jadwal_schedule_service.dart';
import '../widgets/logout_button.dart';

/// Konten tab "Home". Dipakai di dalam AdminShellPage (bersama bottom nav).
class AdminDashboardHome extends StatelessWidget {
  const AdminDashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final artikelController = Get.put(ArtikelController());
    final anakController = Get.put(AnakController());
    final jadwalController = Get.put(JadwalController());
    final masterController = Get.put(JadwalMasterController());
    final vaksinController = Get.put(VaksinController());
    final riwayatController = Get.put(RiwayatController());
    final scheduleService = JadwalScheduleService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medikidz'),
        actions: const [LogoutButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Ringkasan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // --- Card khusus: kebutuhan vaksin bulan ini & peringatan stok menipis ---
          Obx(() {
            final vaksinBulanIni = scheduleService.countJadwalBulanIni(
              anakList: anakController.anakList,
              masterList: masterController.jadwalMasterList,
              semuaJadwalImunisasi: jadwalController.jadwalList,
              bulan: DateTime.now(),
            );
            final stokMenipis = vaksinController.vaksinList
                .where((v) => v.statusStok == 'menipis' || v.statusStok == 'kosong')
                .length;

            return Row(
              children: [
                Expanded(
                  child: _RingkasanCard(
                    icon: Icons.event_available,
                    iconColor: Colors.blue,
                    label: 'Vaksin Diperlukan',
                    sublabel: 'Estimasi dosis bulan ini',
                    value: '$vaksinBulanIni',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const KelolaJadwalListPage())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RingkasanCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: stokMenipis > 0 ? Colors.red : Colors.green,
                    label: 'Stok Menipis',
                    sublabel: 'Vaksin perlu di-restock',
                    value: '$stokMenipis',
                    highlight: stokMenipis > 0,
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const VaksinListPage())),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),

          Obx(() {
            final jumlahArtikel = artikelController.artikelList.length;
            final jumlahRiwayat = riwayatController.riwayatList.length;

            return Row(
              children: [
                Expanded(
                  child: _RingkasanCard(
                    icon: Icons.description_outlined,
                    iconColor: Colors.teal,
                    label: 'Artikel',
                    sublabel: 'Total artikel tersedia',
                    value: '$jumlahArtikel',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const ArtikelListPage())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RingkasanCard(
                    icon: Icons.menu_book_outlined,
                    iconColor: Colors.teal,
                    label: 'Riwayat Imunisasi',
                    sublabel: 'Riwayat luar faskes',
                    value: '$jumlahRiwayat',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const RiwayatListPage())),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),

          Obx(() {
            final now = DateTime.now();
            final jadwalHariIni = jadwalController.jadwalList.where((j) {
              final t = j.tanggalImunisasi;
              return t.year == now.year && t.month == now.month && t.day == now.day;
            }).length;

            return _RingkasanCard(
              icon: Icons.calendar_today_outlined,
              iconColor: Colors.teal,
              label: 'Jadwal Hari Ini',
              sublabel: 'Jadwal imunisasi hari ini',
              value: '$jadwalHariIni',
              fullWidth: true,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const KelolaJadwalListPage())),
            );
          }),

          const SizedBox(height: 24),
          const Text('Menu Cepat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _MenuCepatItem(
                icon: Icons.child_care,
                label: 'Data\nAnak',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnakListPage()),
                ),
              ),
              _MenuCepatItem(
                icon: Icons.vaccines,
                label: 'Vaksin',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VaksinListPage()),
                ),
              ),
              _MenuCepatItem(
                icon: Icons.description_outlined,
                label: 'Artikel',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ArtikelListPage()),
                ),
              ),
              _MenuCepatItem(
                icon: Icons.calendar_month_outlined,
                label: 'Jadwal\nImunisasi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KelolaJadwalListPage()),
                ),
              ),
              _MenuCepatItem(
                icon: Icons.add_box_outlined,
                label: 'Riwayat\nImunisasi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RiwayatListPage()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Belum ada aktivitas tercatat. Log aktivitas otomatis akan muncul di sini '
                'setelah fitur pencatatan aktivitas (audit trail) dibangun.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingkasanCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final String value;
  final bool fullWidth;
  final bool highlight;
  final VoidCallback onTap;

  const _RingkasanCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onTap,
    this.fullWidth = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight ? Colors.red.withOpacity(0.05) : null,
      shape: highlight
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withOpacity(0.4)),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(sublabel, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                  if (highlight)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Icon(Icons.priority_high, size: 10, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: onTap, child: const Text('Lihat')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCepatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCepatItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Icon(icon, color: Colors.teal),
              ),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
