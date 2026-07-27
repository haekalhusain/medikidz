import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/anak_model.dart';
import '../../../models/jadwal_model.dart';
import '../../../services/jadwal_schedule_service.dart';
import '../../../services/jadwal_status_updater.dart';
import 'jadwal_matrix_widget.dart';
import '../jadwal/jadwal_form_page.dart';

class AnakJadwalPage extends StatelessWidget {
  final Anak anak;
  AnakJadwalPage({super.key, required this.anak});

  final JadwalMasterController _masterController = Get.put(JadwalMasterController());
  final JadwalController _jadwalController = Get.put(JadwalController());
  final VaksinController _vaksinController = Get.put(VaksinController());
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jadwal - ${anak.namaAnak}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JadwalFormPage(anakTerpilih: anak)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
      ),
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
            Text('Rencana Imunisasi 0-24 Bulan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'Ditampilkan sebagai matriks seperti standar tabel imunisasi. '
              'Kotak dengan tanda centang berarti sudah diimunisasi.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            JadwalMatrixWidget(jadwal: jadwal),

            const SizedBox(height: 28),
            Text('Rincian Lengkap (Termasuk >24 Bulan)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'Ketuk salah satu baris untuk lihat jadwal seharusnya & ubah status imunisasi.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ..._buildRincianList(context, jadwal),

            const SizedBox(height: 28),
            Text('Riwayat Imunisasi (dari Jadwal)', style: Theme.of(context).textTheme.titleMedium),
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

  List<Widget> _buildRincianList(BuildContext context, List<JadwalTerjadwal> jadwal) {
    return jadwal.map((j) {
      final color = j.sudah
          ? Colors.green
          : (j.statusLabel == 'Terlambat' ? Colors.red : Colors.orange);
      final statusValue = j.sudah ? 'sudah imunisasi' : 'belum imunisasi';

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(j.sudah ? Icons.check : Icons.schedule, color: color, size: 18),
          ),
          title: Text('${j.master.namaVaksin} - Dosis ${j.master.urutanDosis}'),
          subtitle: Text('Usia: ${j.master.usiaLabel}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              j.statusLabel,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jadwal Seharusnya: ${_formatDate(j.tanggalJadwal)}'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Status Imunisasi:'),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: statusValue,
                        items: const [
                          DropdownMenuItem(value: 'belum imunisasi', child: Text('Belum Imunisasi')),
                          DropdownMenuItem(value: 'sudah imunisasi', child: Text('Sudah Imunisasi')),
                        ],
                        onChanged: (value) {
                          if (value == null || value == statusValue) return;
                          _ubahStatus(context, j, value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _ubahStatus(BuildContext context, JadwalTerjadwal item, String status) async {
    final success = await JadwalStatusUpdater.ubahStatus(
      jadwalController: _jadwalController,
      vaksinController: _vaksinController,
      anak: anak,
      item: item,
      status: status,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status ${item.master.namaVaksin} diubah jadi "$status".')),
      );
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
