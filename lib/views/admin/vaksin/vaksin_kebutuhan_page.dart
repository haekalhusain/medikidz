import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../services/jadwal_schedule_service.dart';
import '../widgets/admin_header.dart';

/// Halaman "Kebutuhan Vaksin": menghitung otomatis berapa dosis tiap jenis
/// vaksin yang dibutuhkan bulan ini (berdasarkan jadwal imunisasi seharusnya
/// per anak), lalu membandingkannya dengan stok yang ada di tb_vaksin.
///
/// Semua perhitungan murni di client (lihat JadwalScheduleService), tidak ada
/// tulis-menulis ke Firestore di sini -- jadi aman selalu up-to-date tiap kali
/// data anak/jadwal master/stok berubah.
class VaksinKebutuhanPage extends StatelessWidget {
  const VaksinKebutuhanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final anakController = Get.put(AnakController());
    final masterController = Get.put(JadwalMasterController());
    final jadwalController = Get.put(JadwalController());
    final vaksinController = Get.put(VaksinController());
    final scheduleService = JadwalScheduleService();

    final now = DateTime.now();
    final namaBulan = _namaBulan(now.month);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: buildAdminTopBar(context),
      body: SafeArea(
        child: Obx(() {
          if (masterController.jadwalMasterList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Jadwal master belum diisi. Isi dulu lewat menu "Jadwal Master" di dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            );
          }

          final kebutuhan = scheduleService.hitungKebutuhanVaksin(
            anakList: anakController.anakList,
            masterList: masterController.jadwalMasterList,
            semuaJadwalImunisasi: jadwalController.jadwalList,
            vaksinList: vaksinController.vaksinList,
            bulan: now,
          );

          final totalKekurangan = kebutuhan.fold<int>(0, (sum, k) => sum + k.kekurangan);
          final totalJenis = kebutuhan.length;
          final totalCukup = kebutuhan.where((k) => k.cukup && k.terdaftarDiStok).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kebutuhan Vaksin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Estimasi kebutuhan bulan ini',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimasi Kebutuhan - $namaBulan ${now.year}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dihitung dari jadwal imunisasi seharusnya seluruh anak yang belum direalisasikan, dibandingkan dengan stok vaksin saat ini.',
                      style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _SummaryBadge(
                      title: 'Jenis Vaksin',
                      value: '$totalJenis',
                      color: const Color(0xFF00A88F),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryBadge(
                      title: 'Stok Vaksin Mencukupi',
                      value: '$totalCukup',
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),

              // Row untuk "Kurang" dan "Belum Daftar" beserta SizedBox-nya sudah DIHAPUS di sini

              const SizedBox(height: 20),
              if (totalKekurangan > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEB),
                    border: Border.all(color: const Color(0xFFF4C1C0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFE55335), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ada $totalKekurangan dosis yang stoknya belum cukup. Segera lengkapi stok vaksin yang kurang.',
                          style: const TextStyle(
                            color: Color(0xFFE55335),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (kebutuhan.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Tidak ada jadwal imunisasi yang jatuh bulan ini.',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ),
                )
              else
                ...kebutuhan.map((k) => _KebutuhanCard(kebutuhan: k)),
              const SizedBox(height: 24),
            ],
          );
        }),
      ),
    );
  }

  String _namaBulan(int bulan) {
    const nama = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return nama[bulan - 1];
  }
}

class _KebutuhanCard extends StatelessWidget {
  final KebutuhanVaksin kebutuhan;

  const _KebutuhanCard({required this.kebutuhan});

  Color get _accentColor {
    if (!kebutuhan.terdaftarDiStok) return const Color(0xFF7B8FA1);
    return kebutuhan.cukup ? const Color(0xFF00A88F) : const Color(0xFFE55335);
  }

  String get _statusLabel {
    if (!kebutuhan.terdaftarDiStok) return 'Belum terdaftar';
    return kebutuhan.cukup ? 'Stok Cukup' : 'Stok Kurang';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.vaccines, color: _accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    kebutuhan.namaVaksin,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    _statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(child: _statBlock('Dibutuhkan', '${kebutuhan.dibutuhkan}')),
                Expanded(child: _statBlock('Stok Tersedia', '${kebutuhan.stokTersedia}')),
                Expanded(child: _statBlock('Kekurangan', '${kebutuhan.kekurangan}')),
              ],
            ),
          ),
          if (!kebutuhan.terdaftarDiStok)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: const Text(
                'Vaksin ini belum terdaftar di menu Data Vaksin, jadi stoknya dianggap 0. Tambahkan datanya supaya perbandingan stok akurat.',
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryBadge({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: color.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
