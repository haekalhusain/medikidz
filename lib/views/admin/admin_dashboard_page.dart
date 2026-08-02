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
  final ValueChanged<int>? onNavigateToTab;

  const AdminDashboardHome({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final artikelController = Get.put(ArtikelController());
    final anakController = Get.put(AnakController());
    final jadwalController = Get.put(JadwalController());
    final masterController = Get.put(JadwalMasterController());
    final vaksinController = Get.put(VaksinController());
    final scheduleService = JadwalScheduleService();

    // Palette Warna Sesuai Desain Gambar
    final primaryTeal = const Color(0xFF38B2AC);
    final lightTealBg = const Color(0xFFE6FFFA);
    final cardBgColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.child_care, color: primaryTeal, size: 30),
              ),
              const SizedBox(height: 2),
              Image.asset(
                'assets/logo2.png',
                height: 12,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text(
                  'KLINIK & APOTEK MediKidz',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Tombol Notifikasi (Desain Bulat dengan Badge Merah seperti di gambar)
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFE6FFFA),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: primaryTeal,
                      size: 22,
                    ),
                    onPressed: () {
                      // Belum ada fungsi
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tombol Logout bawaan
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFE6FFFA),
                shape: BoxShape.circle,
              ),
              child: const LogoutButton(),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ringkasan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // --- 5 Card Ringkasan (Layout Grid 2 Kolom seperti di Gambar) ---
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
            final jumlahArtikel = artikelController.artikelList.length;
            final jumlahAnak = anakController.anakList.length;

            final now = DateTime.now();
            final jadwalHariIni = jadwalController.jadwalList.where((j) {
              final t = j.tanggalImunisasi;
              return t.year == now.year &&
                  t.month == now.month &&
                  t.day == now.day;
            }).length;

            return Column(
              children: [
                // Baris 1: Vaksin Diperlukan & Stok Menipis
                Row(
                  children: [
                    Expanded(
                      child: _RingkasanCard(
                        icon: Icons.event_available,
                        iconBgColor: const Color(0xFFFFFAF0),
                        iconColor: const Color(0xFFDD6B20),
                        label: 'Vaksin Diperlukan',
                        sublabel: 'Estimasi dosis bulan ini',
                        value: '$vaksinBulanIni',
                        buttonText: 'Periksa',
                        buttonBgColor: const Color(0xFFFEEBC8),
                        buttonTextColor: const Color(0xFFC05621),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VaksinKebutuhanPage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RingkasanCard(
                        icon: Icons.calendar_today_outlined,
                        iconBgColor: lightTealBg,
                        iconColor: primaryTeal,
                        label: 'Jadwal Hari Ini',
                        sublabel: 'Jadwal imunisasi hari ini',
                        value: '$jadwalHariIni',
                        buttonText: 'Lihat',
                        buttonBgColor: lightTealBg,
                        buttonTextColor: primaryTeal,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const KelolaJadwalListPage(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Baris 2: Artikel & Riwayat Imunisasi
                Row(
                  children: [
                    Expanded(
                      child: _RingkasanCard(
                        icon: Icons.description_outlined,
                        iconBgColor: lightTealBg,
                        iconColor: primaryTeal,
                        label: 'Artikel',
                        sublabel: 'Total artikel tersedia',
                        value: '$jumlahArtikel',
                        buttonText: 'Lihat',
                        buttonBgColor: lightTealBg,
                        buttonTextColor: primaryTeal,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ArtikelListPage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RingkasanCard(
                        icon: Icons.medical_services_outlined,
                        iconBgColor: lightTealBg,
                        iconColor: primaryTeal,
                        label: 'Riwayat Imunisasi',
                        sublabel: 'Total anak terdaftar',
                        value: '$jumlahAnak',
                        buttonText: 'Lihat',
                        buttonBgColor: lightTealBg,
                        buttonTextColor: primaryTeal,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnakListPage(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Baris 3: Stok Menipis (Card ke-5)
                Row(
                  children: [
                    Expanded(
                      child: _RingkasanCard(
                        icon: Icons.warning_amber_rounded,
                        iconBgColor: stokMenipis > 0
                            ? const Color(0xFFFFF5F5)
                            : lightTealBg,
                        iconColor:
                            stokMenipis > 0 ? Colors.red : primaryTeal,
                        label: 'Stok Menipis',
                        sublabel: 'Vaksin perlu di-restock',
                        value: '$stokMenipis',
                        buttonText: 'Periksa',
                        buttonBgColor: stokMenipis > 0
                            ? const Color(0xFFFED7D7)
                            : lightTealBg,
                        buttonTextColor:
                            stokMenipis > 0 ? Colors.red : primaryTeal,
                        onTap: () {
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(1);
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VaksinListPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()), // Balancer layout grid
                  ],
                ),
              ],
            );
          }),

          const SizedBox(height: 24),
          const Text(
            'Menu Cepat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Box Container Putih untuk Menu Cepat Sesuai Gambar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MenuCepatItem(
                  icon: Icons.vaccines_outlined,
                  label: 'Vaksin',
                  onTap: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(1);
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VaksinListPage()),
                    );
                  },
                ),
                _MenuCepatItem(
                  icon: Icons.description_outlined,
                  label: 'Artikel',
                  onTap: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(2);
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ArtikelListPage(),
                      ),
                    );
                  },
                ),
                _MenuCepatItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Jadwal\nImunisasi',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const KelolaJadwalListPage(),
                    ),
                  ),
                ),
                _MenuCepatItem(
                  icon: Icons.medical_services_outlined,
                  label: 'Riwayat\nImunisasi',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AnakListPage()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Lihat semua',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: primaryTeal,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Aktivitas Terbaru Card
          StreamBuilder<List<ActivityLogEntry>>(
            stream: ActivityLogService.streamTerbaru(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Belum ada aktivitas tercatat. Aktivitas seperti tambah vaksin, tambah artikel, '
                    'dan pencatatan imunisasi akan muncul di sini.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                );
              }

              final data = snapshot.data!;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < data.length; i++) ...[
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: lightTealBg,
                          child: Icon(
                            _ikonKategori(data[i].kategori),
                            color: primaryTeal,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          data[i].pesan,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _formatWaktu(data[i].waktu),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.black26,
                          size: 18,
                        ),
                      ),
                      if (i != data.length - 1)
                        const Divider(height: 1, indent: 60, endIndent: 16),
                    ],
                  ],
                ),
              );
            },
          ),

          // Jarak kosongan (Padding tambahan) di paling bawah agar tidak tertutup Shell Bottom Nav Bar
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  IconData _ikonKategori(String kategori) {
    switch (kategori) {
      case 'vaksin':
        return Icons.vaccines_outlined;
      case 'artikel':
        return Icons.description_outlined;
      case 'imunisasi':
        return Icons.check_circle_outline;
      default:
        return Icons.person_outline;
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

// Widget Card Ringkasan dengan styling bundar khas Gambar UI
class _RingkasanCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String sublabel;
  final String value;
  final String buttonText;
  final Color buttonBgColor;
  final Color buttonTextColor;
  final VoidCallback onTap;

  const _RingkasanCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.buttonText,
    required this.buttonBgColor,
    required this.buttonTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconBgColor,
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: buttonBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: buttonTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Item Menu Cepat
class _MenuCepatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCepatItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE6FFFA),
            child: Icon(icon, color: const Color(0xFF38B2AC), size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
