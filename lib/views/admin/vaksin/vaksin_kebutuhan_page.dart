import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../services/jadwal_schedule_service.dart';

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
      appBar: AppBar(title: const Text('Kebutuhan Vaksin')),
      body: Obx(() {
        if (masterController.jadwalMasterList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Jadwal master belum diisi. Isi dulu lewat menu "Jadwal Master" di dashboard.',
                textAlign: TextAlign.center,
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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Estimasi Kebutuhan - $namaBulan ${now.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Dihitung dari jadwal imunisasi seharusnya seluruh anak yang belum '
              'direalisasikan, dibandingkan dengan stok vaksin saat ini.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (totalKekurangan > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ada $totalKekurangan dosis (gabungan semua jenis) yang stoknya belum cukup.',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            if (kebutuhan.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Tidak ada jadwal imunisasi yang jatuh bulan ini.'),
                ),
              )
            else
              ...kebutuhan.map((k) => _KebutuhanCard(kebutuhan: k)),
          ],
        );
      }),
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
    if (!kebutuhan.terdaftarDiStok) return Colors.grey;
    return kebutuhan.cukup ? Colors.teal : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.06),
        border: Border.all(color: _accentColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vaccines, color: _accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    kebutuhan.namaVaksin,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    !kebutuhan.terdaftarDiStok
                        ? 'Belum ada di stok'
                        : (kebutuhan.cukup ? 'Stok Cukup' : 'Stok Kurang'),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statBlock('Dibutuhkan', '${kebutuhan.dibutuhkan}'),
                const SizedBox(width: 20),
                _statBlock('Stok Tersedia', '${kebutuhan.stokTersedia}'),
                const SizedBox(width: 20),
                _statBlock('Kekurangan', '${kebutuhan.kekurangan}'),
              ],
            ),
            if (!kebutuhan.terdaftarDiStok) ...[
              const SizedBox(height: 8),
              const Text(
                'Vaksin ini belum terdaftar di menu Data Vaksin, jadi stoknya dianggap 0. '
                'Tambahkan datanya supaya perbandingan stok akurat.',
                style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
