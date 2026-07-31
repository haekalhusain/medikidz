import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/jadwal_schedule_service.dart';
import '../../admin/anak/jadwal_matrix_widget.dart';

/// Versi READ-ONLY dari jadwal imunisasi anak (khusus orang tua/user).
/// Tidak ada tombol ubah status -- itu wewenang admin/perawat di klinik.
class AnakSayaJadwalPage extends StatelessWidget {
  final Anak anak;
  AnakSayaJadwalPage({super.key, required this.anak});

  final JadwalMasterController _masterController = Get.put(JadwalMasterController());
  final JadwalController _jadwalController = Get.put(JadwalController());
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jadwal - ${anak.namaAnak}')),
      body: Obx(() {
        final masterList = _masterController.jadwalMasterList;
        if (masterList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Jadwal imunisasi belum tersedia. Hubungi klinik.', textAlign: TextAlign.center),
            ),
          );
        }

        final jadwal = _scheduleService.computeJadwalForAnak(
          anak: anak,
          masterList: masterList,
          semuaJadwalImunisasi: _jadwalController.jadwalList,
        );

        final riwayat = jadwal.where((j) => j.sudah).toList()
          ..sort((a, b) => b.realisasi!.tanggalImunisasi.compareTo(a.realisasi!.tanggalImunisasi));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Rencana Imunisasi 2 Tahun ke Depan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            JadwalMatrixWidget(jadwal: jadwal),

            const SizedBox(height: 24),
            Text('Rincian Lengkap', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...jadwal.map((j) {
              final color =
                  j.sudah ? Colors.green : (j.statusLabel == 'Terlambat' ? Colors.red : Colors.orange);
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: Icon(j.sudah ? Icons.check_circle : Icons.schedule, color: color),
                  title: Text('${j.master.namaVaksin} - Dosis ${j.master.urutanDosis}'),
                  subtitle: Text('Usia: ${j.master.usiaLabel}  •  Jadwal: ${_formatDate(j.tanggalJadwal)}'),
                  trailing: Text(j.statusLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              );
            }),

            const SizedBox(height: 24),
            Text('Riwayat Imunisasi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (riwayat.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Belum ada imunisasi yang tercatat.'),
              )
            else
              ...riwayat.map((j) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text('${j.master.namaVaksin} - Dosis ${j.master.urutanDosis}'),
                      subtitle: Text(_formatDate(j.realisasi!.tanggalImunisasi)),
                    ),
                  )),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
