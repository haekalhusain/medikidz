import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'vaksin/vaksin_list_page.dart';
import 'vaksin/vaksin_kebutuhan_page.dart';
import 'artikel/artikel_list_page.dart';
import 'anak/anak_list_page.dart';
import 'jadwal/kelola_jadwal_list_page.dart';
import '../../controllers/artikel_controller.dart';
import '../../controllers/anak_controller.dart';
import '../../controllers/jadwal_controller.dart';
import '../../controllers/jadwal_master_controller.dart';
import '../../controllers/vaksin_controller.dart';
import '../../services/jadwal_schedule_service.dart';
import '../../services/activity_log_service.dart';
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
                        .push(MaterialPageRoute(builder: (_) => const VaksinKebutuhanPage())),
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
            final jumlahAnak = anakController.anakList.length;

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
                    icon: Icons.child_care,
                    iconColor: Colors.teal,
                    label: 'Riwayat Imunisasi',
                    sublabel: 'Total anak terdaftar',
                    value: '$jumlahAnak',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const AnakListPage())),
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
                label: 'Riwayat\nImunisasi',
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
            ],
          ),

          const SizedBox(height: 24),
          const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<List<ActivityLogEntry>>(
            stream: ActivityLogService.streamTerbaru(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Belum ada aktivitas tercatat. Aktivitas seperti tambah vaksin, tambah artikel, '
                      'dan pencatatan imunisasi akan muncul di sini.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                );
              }

              final data = snapshot.data!;
              return Card(
                child: Column(
                  children: [
                    for (int i = 0; i < data.length; i++) ...[
                      ListTile(
                        dense: true,
                        leading: Icon(_ikonKategori(data[i].kategori), color: _warnaKategori(data[i].kategori)),
                        title: Text(data[i].pesan, style: const TextStyle(fontSize: 13)),
                        subtitle: Text(_formatWaktu(data[i].waktu), style: const TextStyle(fontSize: 11)),
                      ),
                      if (i != data.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _ikonKategori(String kategori) {
    switch (kategori) {
      case 'vaksin':
        return Icons.vaccines;
      case 'artikel':
        return Icons.description_outlined;
      case 'imunisasi':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _warnaKategori(String kategori) {
    switch (kategori) {
      case 'vaksin':
        return Colors.blue;
      case 'artikel':
        return Colors.teal;
      case 'imunisasi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatWaktu(DateTime waktu) {
    final now = DateTime.now();
    final selisih = now.difference(waktu);
    if (selisih.inMinutes < 1) return 'Baru saja';
    if (selisih.inMinutes < 60) return '${selisih.inMinutes} menit lalu';
    if (selisih.inHours < 24) return '${selisih.inHours} jam lalu';
    return '${waktu.day}/${waktu.month}/${waktu.year}';
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
      color: highlight ? Colors.red.withValues(alpha: 0.05) : null,
      shape: highlight
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
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
                    backgroundColor: iconColor.withValues(alpha: 0.1),
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
                backgroundColor: Colors.teal.withValues(alpha: 0.1),
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
