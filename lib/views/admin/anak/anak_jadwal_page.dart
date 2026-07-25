import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/jadwal_schedule_service.dart';

class AnakJadwalPage extends StatelessWidget {
  final Anak anak;
  AnakJadwalPage({super.key, required this.anak});

  final JadwalMasterController _masterController = Get.put(JadwalMasterController());
  final JadwalController _jadwalController = Get.put(JadwalController());
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jadwal - ${anak.namaAnak}')),
      body: Obx(() {
        final masterList = _masterController.jadwalMasterList;
        final jadwalList = _jadwalController.jadwalList;

        if (masterList.isEmpty) {
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

        final jadwal = _scheduleService.computeJadwalForAnak(
          anak: anak,
          masterList: masterList,
          semuaJadwalImunisasi: jadwalList,
        );

        final riwayat = jadwal.where((j) => j.sudah).toList()
          ..sort((a, b) => b.realisasi!.tanggalImunisasi.compareTo(a.realisasi!.tanggalImunisasi));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Rencana Imunisasi (0-24 bulan)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Dihitung otomatis dari tanggal lahir anak.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _buildTable(jadwal),
            const SizedBox(height: 28),
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

  Widget _buildTable(List<JadwalTerjadwal> jadwal) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.teal.withOpacity(0.1)),
        columns: const [
          DataColumn(label: Text('Jenis Imunisasi')),
          DataColumn(label: Text('Dosis')),
          DataColumn(label: Text('Usia')),
          DataColumn(label: Text('Tanggal Jadwal')),
          DataColumn(label: Text('Status')),
        ],
        rows: jadwal.map((j) {
          final color = j.sudah
              ? Colors.green
              : (j.statusLabel == 'Terlambat' ? Colors.red : Colors.orange);
          return DataRow(cells: [
            DataCell(Text(j.master.namaVaksin)),
            DataCell(Text('${j.master.urutanDosis}')),
            DataCell(Text(j.master.usiaLabel)),
            DataCell(Text(_formatDate(j.tanggalJadwal))),
            DataCell(Text(j.statusLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          ]);
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
