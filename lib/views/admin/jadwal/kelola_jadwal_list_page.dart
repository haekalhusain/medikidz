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

enum _FilterStatus { semua, terlambat, akanDatang }

class _KelolaJadwalListPageState extends State<KelolaJadwalListPage> {
  bool _hanyaHariIni = true;
  _FilterStatus _filterStatus = _FilterStatus.semua;
  final _searchController = TextEditingController();
  String _query = '';
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama anak atau nama vaksin..',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                  const SizedBox(width: 16),
                  const VerticalDivider(width: 1),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Terlambat'),
                    selectedColor: Colors.red.withValues(alpha: 0.15),
                    selected: _filterStatus == _FilterStatus.terlambat,
                    onSelected: (_) => setState(() => _filterStatus =
                        _filterStatus == _FilterStatus.terlambat ? _FilterStatus.semua : _FilterStatus.terlambat),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Akan Datang'),
                    selectedColor: Colors.orange.withValues(alpha: 0.15),
                    selected: _filterStatus == _FilterStatus.akanDatang,
                    onSelected: (_) => setState(() => _filterStatus = _filterStatus == _FilterStatus.akanDatang
                        ? _FilterStatus.semua
                        : _FilterStatus.akanDatang),
                  ),
                ],
              ),
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

              var tampil = _hanyaHariIni
                  ? semuaBaris.where((b) {
                      final t = b.item.tanggalJadwal;
                      return t.year == now.year && t.month == now.month && t.day == now.day;
                    }).toList()
                  : semuaBaris;

              if (_filterStatus == _FilterStatus.terlambat) {
                tampil = tampil.where((b) => b.item.statusLabel == 'Terlambat').toList();
              } else if (_filterStatus == _FilterStatus.akanDatang) {
                tampil = tampil.where((b) => b.item.statusLabel == 'Akan Datang').toList();
              }

              if (_query.isNotEmpty) {
                tampil = tampil
                    .where((b) =>
                        b.anak.namaAnak.toLowerCase().contains(_query) ||
                        b.item.master.namaVaksin.toLowerCase().contains(_query))
                    .toList();
              }

              if (tampil.isEmpty) {
                return const Center(child: Text('Tidak ada jadwal yang cocok dengan filter/pencarian.'));
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

  Future<void> _konfirmasi(
    BuildContext context,
    JadwalController jadwalController,
    VaksinController vaksinController,
    _BarisJadwal baris,
  ) async {
    final vaksinDariKlinik = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Imunisasi'),
        content: Text(
          'Tandai "${baris.item.master.namaVaksin}" untuk ${baris.anak.namaAnak} sebagai SUDAH diimunisasi?\n\n'
          'Apakah vaksinnya dari stok klinik ini? Kalau "Ya", stok otomatis dikurangi 1.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ya, Tapi Bukan dari Klinik')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, dari Klinik')),
        ],
      ),
    );

    if (vaksinDariKlinik == null || !context.mounted) return;

    await JadwalStatusUpdater.ubahStatus(
      jadwalController: jadwalController,
      vaksinController: vaksinController,
      anak: baris.anak,
      item: baris.item,
      status: 'sudah imunisasi',
      vaksinDariKlinik: vaksinDariKlinik,
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _BarisJadwal {
  final Anak anak;
  final JadwalTerjadwal item;
  _BarisJadwal({required this.anak, required this.item});
}
