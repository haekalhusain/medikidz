import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/anak_model.dart';
import '../../../models/jadwal_master_model.dart';
import '../../../services/jadwal_schedule_service.dart';
import '../../../services/jadwal_status_updater.dart';
import '../../../utils/date_formatter.dart';
import 'jadwal_matrix_widget.dart';
import '../jadwal/jadwal_form_page.dart';

class AnakJadwalPage extends StatelessWidget {
  final Anak anak;
  AnakJadwalPage({super.key, required this.anak});

  final JadwalMasterController _masterController = Get.find<JadwalMasterController>();
  final JadwalController _jadwalController = Get.find<JadwalController>();
  final VaksinController _vaksinController = Get.find<VaksinController>();
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Jadwal - ${anak.namaAnak}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JadwalFormPage(anakTerpilih: anak)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
        backgroundColor: const Color(0xFF359D89),
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan imunisasi anak',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau jadwal, riwayat, dan status imunisasi secara lebih rapi dan mudah dibaca.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Rencana Imunisasi 2 Tahun ke Depan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text(
              'Ditampilkan sebagai matriks seperti standar tabel imunisasi (0-24 bulan). '
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
            ..._buildRincianList(context, jadwal, masterList),

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

  List<Widget> _buildRincianList(BuildContext context, List<JadwalTerjadwal> jadwal, List<JadwalMaster> masterList) {
    return jadwal.map((j) {
      final color = j.sudah
          ? Colors.green
          : j.dilewati
              ? Colors.blueGrey
              : j.tidakBisaDikejar
                  ? Colors.grey
                  : (j.statusLabel == 'Terlambat' ? Colors.red : Colors.orange);
      final statusValue = _currentStatusValue(j);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(j.sudah ? Icons.check : Icons.schedule, color: color, size: 18),
          ),
          title: Text('${j.master.namaVaksin} - Dosis ${j.master.urutanDosis}'),
          subtitle: Text('Usia: ${j.master.usiaLabel}${j.sudahDijadwalUlang ? ' • dijadwal ulang' : ''}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: statusValue,
                          items: const [
                            DropdownMenuItem(value: 'belum imunisasi', child: Text('Belum Imunisasi')),
                            DropdownMenuItem(value: 'sudah imunisasi', child: Text('Sudah Imunisasi')),
                            DropdownMenuItem(value: 'dilewati', child: Text('Tidak Perlu Dikejar')),
                            DropdownMenuItem(value: 'tidak bisa dikejar', child: Text('Tidak Bisa Dikejar')),
                          ],
                          onChanged: (value) {
                            if (value == null || value == statusValue) return;
                            _handlePilihStatus(context, j, value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _editJadwalManual(context, j, masterList),
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: const Text('Ubah Jadwal (Pengejaran)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _currentStatusValue(JadwalTerjadwal j) {
    if (j.sudah) return 'sudah imunisasi';
    if (j.dilewati) return 'dilewati';
    if (j.tidakBisaDikejar) return 'tidak bisa dikejar';
    return 'belum imunisasi';
  }

  Future<void> _editJadwalManual(BuildContext context, JadwalTerjadwal item, List<JadwalMaster> masterList) async {
    final acuanSebelumnya = _scheduleService.tanggalAcuanDosisSebelumnya(
      anak: anak,
      masterList: masterList,
      semuaJadwalImunisasi: _jadwalController.jadwalList,
      masterSaatIni: item.master,
    );

    DateTime? batasMinimum;
    if (acuanSebelumnya != null && item.master.intervalMinimumPengejaranHari != null) {
      batasMinimum = acuanSebelumnya.add(Duration(days: item.master.intervalMinimumPengejaranHari!));
    }

    DateTime? batasMaksimal;
    if (item.master.usiaMaksimalHari != null) {
      batasMaksimal = anak.tanggalLahir.add(Duration(days: item.master.usiaMaksimalHari!));
    }

    final tanggalTerpilih = await showDatePicker(
      context: context,
      initialDate: item.tanggalJadwal.isBefore(DateTime.now()) ? DateTime.now() : item.tanggalJadwal,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (tanggalTerpilih == null || !context.mounted) return;

    final peringatan = <String>[];
    if (batasMinimum != null && tanggalTerpilih.isBefore(batasMinimum)) {
      peringatan.add(
        'Tanggal ini kurang dari interval minimum pengejaran (${item.master.intervalMinimumPengejaranHari} hari '
        'dari dosis sebelumnya, minimal ${_formatDate(batasMinimum)}).',
      );
    }
    if (batasMaksimal != null && tanggalTerpilih.isAfter(batasMaksimal)) {
      peringatan.add(
        'Tanggal ini melewati batas usia maksimal pemberian vaksin ini (maksimal ${_formatDate(batasMaksimal)}).',
      );
    }

    if (peringatan.isNotEmpty && context.mounted) {
      final lanjut = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('⚠ Perlu Diperhatikan'),
          content: Text(peringatan.join('\n\n')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tetap Lanjutkan')),
          ],
        ),
      );
      if (lanjut != true) return;
    }

    if (!context.mounted) return;
    final success = await JadwalStatusUpdater.jadwalUlangManual(
      jadwalController: _jadwalController,
      anak: anak,
      item: item,
      tanggalBaru: tanggalTerpilih,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jadwal ${item.master.namaVaksin} diubah ke ${_formatDate(tanggalTerpilih)}.')),
      );
    }
  }

  Future<void> _handlePilihStatus(BuildContext context, JadwalTerjadwal item, String status) async {
    if (status != 'sudah imunisasi') {
      await _ubahStatus(context, item, status, vaksinDariKlinik: false);
      return;
    }

    final vaksinDariKlinik = await _tanyaVaksinKlinik(context);
    if (vaksinDariKlinik == null) return; // dibatalkan
    await _ubahStatus(context, item, status, vaksinDariKlinik: vaksinDariKlinik);
  }

  Future<bool?> _tanyaVaksinKlinik(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vaksin Klinik?'),
        content: const Text(
          'Apakah vaksin yang dipakai berasal dari stok klinik ini? '
          'Kalau "Ya", stok vaksin akan otomatis dikurangi 1.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );
  }

  Future<void> _ubahStatus(
    BuildContext context,
    JadwalTerjadwal item,
    String status, {
    required bool vaksinDariKlinik,
  }) async {
    final success = await JadwalStatusUpdater.ubahStatus(
      jadwalController: _jadwalController,
      vaksinController: _vaksinController,
      anak: anak,
      item: item,
      status: status,
      vaksinDariKlinik: vaksinDariKlinik,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status ${item.master.namaVaksin} diubah jadi "$status".')),
      );
    }
  }

  String _formatDate(DateTime date) => formatTanggal(date);
}
