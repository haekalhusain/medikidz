import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/anak_controller.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/jadwal_schedule_service.dart';
import '../../../services/jadwal_status_updater.dart';

/// Menampilkan jadwal imunisasi yang DIHITUNG OTOMATIS untuk semua anak,
/// berdasarkan tanggal lahir tiap anak (tb_anak) + template (tb_jadwalMaster).
/// Tidak perlu input manual satu-satu -- begitu ada anak baru atau
/// Jadwal Master diperbarui, daftar ini otomatis ikut menyesuaikan.
class KelolaJadwalListPage extends StatefulWidget {
  const KelolaJadwalListPage({super.key});

  @override
  State<KelolaJadwalListPage> createState() => _KelolaJadwalListPageState();
}

class _KelolaJadwalListPageState extends State<KelolaJadwalListPage> {
  bool _hanyaHariIni = true;
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  Widget build(BuildContext context) {
    final anakController = Get.put(AnakController());
    final masterController = Get.put(JadwalMasterController());
    final jadwalController = Get.put(JadwalController());
    final vaksinController = Get.put(VaksinController());

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Imunisasi')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Jatuh Tempo Hari Ini'),
                  selected: _hanyaHariIni,
                  onSelected: (_) => setState(() => _hanyaHariIni = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Semua Jadwal'),
                  selected: !_hanyaHariIni,
                  onSelected: (_) => setState(() => _hanyaHariIni = false),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final masterList = masterController.jadwalMasterList;
              if (masterList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Jadwal master belum diisi. Isi dulu lewat menu "Jadwal Master".',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              // Gabungkan rencana imunisasi semua anak jadi satu daftar.
              final now = DateTime.now();
              final semuaBaris = <_BarisJadwal>[];
              for (final anak in anakController.anakList) {
                final jadwal = _scheduleService.computeJadwalForAnak(
                  anak: anak,
                  masterList: masterList,
                  semuaJadwalImunisasi: jadwalController.jadwalList,
                );
                for (final j in jadwal) {
                  if (j.sudah) continue; // yang sudah selesai tidak perlu masuk worklist
                  semuaBaris.add(_BarisJadwal(anak: anak, item: j));
                }
              }

              semuaBaris.sort((a, b) => a.item.tanggalJadwal.compareTo(b.item.tanggalJadwal));

              final tampil = _hanyaHariIni
                  ? semuaBaris.where((b) {
                      final t = b.item.tanggalJadwal;
                      return t.year == now.year && t.month == now.month && t.day == now.day;
                    }).toList()
                  : semuaBaris;

              if (tampil.isEmpty) {
                return Center(
                  child: Text(_hanyaHariIni
                      ? 'Tidak ada jadwal yang jatuh tempo hari ini.'
                      : 'Belum ada anak terdaftar / semua jadwal sudah selesai.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: tampil.length,
                itemBuilder: (context, index) {
                  final baris = tampil[index];
                  final terlambat = baris.item.statusLabel == 'Terlambat';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        terlambat ? Icons.warning_amber_rounded : Icons.schedule,
                        color: terlambat ? Colors.red : Colors.orange,
                      ),
                      title: Text('${baris.item.master.namaVaksin} — Dosis ${baris.item.master.urutanDosis}'),
                      subtitle: Text(
                        '${baris.anak.namaAnak}\n${_formatDate(baris.item.tanggalJadwal)}  •  ${baris.item.statusLabel}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Tandai sudah imunisasi',
                        onPressed: () => _konfirmasi(context, jadwalController, vaksinController, baris),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _konfirmasi(
    BuildContext context,
    JadwalController jadwalController,
    VaksinController vaksinController,
    _BarisJadwal baris,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Imunisasi'),
        content: Text(
            'Tandai "${baris.item.master.namaVaksin}" untuk ${baris.anak.namaAnak} sebagai SUDAH diimunisasi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await JadwalStatusUpdater.ubahStatus(
                jadwalController: jadwalController,
                vaksinController: vaksinController,
                anak: baris.anak,
                item: baris.item,
                status: 'sudah imunisasi',
              );
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _BarisJadwal {
  final Anak anak;
  final JadwalTerjadwal item;
  _BarisJadwal({required this.anak, required this.item});
}
