import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../models/jadwal_master_model.dart';

class JadwalMasterFormPage extends StatefulWidget {
  final JadwalMaster item;
  const JadwalMasterFormPage({super.key, required this.item});

  @override
  State<JadwalMasterFormPage> createState() => _JadwalMasterFormPageState();
}

class _JadwalMasterFormPageState extends State<JadwalMasterFormPage> {
  late String _kategoriJendela;
  late TextEditingController _toleransiController;
  late TextEditingController _catatanController;
  late TextEditingController _intervalPengejaranController;
  late TextEditingController _usiaMaksimalController;

  @override
  void initState() {
    super.initState();
    _kategoriJendela = widget.item.kategoriJendelaPengejaran;
    _toleransiController = TextEditingController(text: widget.item.toleransiKeterlambatanHari?.toString() ?? '');
    _catatanController = TextEditingController(text: widget.item.catatanMedis ?? '');
    _intervalPengejaranController =
        TextEditingController(text: widget.item.intervalMinimumPengejaranHari?.toString() ?? '');
    _usiaMaksimalController = TextEditingController(text: widget.item.usiaMaksimalHari?.toString() ?? '');
  }

  @override
  void dispose() {
    _toleransiController.dispose();
    _catatanController.dispose();
    _intervalPengejaranController.dispose();
    _usiaMaksimalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JadwalMasterController>();
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text('${item.namaVaksin} — Dosis ${item.urutanDosis}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usia jadwal: ${item.usiaLabel}', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Kategori: ${item.kategori}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Toleransi Keterlambatan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Text(
              'Bagian ini bisa diubah kapan saja oleh admin/staff, sesuai kebijakan klinik.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategoriJendela,
              decoration: const InputDecoration(labelText: 'Kategori Jendela Pengejaran', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'luas', child: Text('Luas — bisa dikejar kapan saja')),
                DropdownMenuItem(value: 'terbatas', child: Text('Terbatas — ada batas akhir')),
                DropdownMenuItem(value: 'tanpa jendela', child: Text('Tanpa jendela — harus tepat waktu')),
              ],
              onChanged: (value) {
                setState(() {
                  _kategoriJendela = value!;
                  if (_kategoriJendela == 'tanpa jendela') _toleransiController.text = '';
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _toleransiController,
              enabled: _kategoriJendela != 'tanpa jendela',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Toleransi Keterlambatan (hari)',
                border: const OutlineInputBorder(),
                helperText: _kategoriJendela == 'tanpa jendela'
                    ? 'Tidak berlaku untuk kategori "tanpa jendela"'
                    : 'Berapa hari boleh telat sebelum dianggap lewat batas',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan Medis (opsional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Pengaturan Pengejaran Dosis (Catch-up)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const Text(
              'Dipakai saat anak ketinggalan dosis ini dan perlu dikejar. '
              'Diisi bebas oleh dokter/staff sesuai kebijakan klinik, bisa diubah kapan saja.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _intervalPengejaranController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Interval Minimum ke Dosis Ini (hari)',
                border: OutlineInputBorder(),
                helperText: 'Jarak minimum dari dosis sebelumnya, kalau dosis ini bagian dari pengejaran',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usiaMaksimalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Usia Maksimal Pemberian (hari)',
                border: OutlineInputBorder(),
                helperText: 'Kosongkan kalau vaksin ini tidak punya batas usia maksimal',
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submit,
                    child: controller.isLoading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Simpan Perubahan'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final controller = Get.find<JadwalMasterController>();
    final item = widget.item;

    final updated = JadwalMaster(
      id: item.id,
      namaVaksin: item.namaVaksin,
      urutanDosis: item.urutanDosis,
      usiaHari: item.usiaHari,
      usiaLabel: item.usiaLabel,
      kategori: item.kategori,
      kategoriJendelaPengejaran: _kategoriJendela,
      toleransiKeterlambatanHari: _toleransiController.text.isEmpty ? null : int.tryParse(_toleransiController.text),
      catatanMedis: _catatanController.text.trim(),
      sumberReferensi: item.sumberReferensi,
      intervalMinimumPengejaranHari:
          _intervalPengejaranController.text.isEmpty ? null : int.tryParse(_intervalPengejaranController.text),
      usiaMaksimalHari: _usiaMaksimalController.text.isEmpty ? null : int.tryParse(_usiaMaksimalController.text),
    );

    final success = await controller.updateData(item.id!, updated);
    if (success && mounted) Navigator.pop(context);
  }
}
