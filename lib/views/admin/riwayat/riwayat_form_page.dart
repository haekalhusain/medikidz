import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/riwayat_controller.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/riwayat_model.dart';

class RiwayatFormPage extends StatefulWidget {
  final RiwayatImunisasi? riwayat;
  const RiwayatFormPage({super.key, this.riwayat});

  @override
  State<RiwayatFormPage> createState() => _RiwayatFormPageState();
}

class _RiwayatFormPageState extends State<RiwayatFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaVaksinController = TextEditingController();
  final _faskesController = TextEditingController();
  final _catatanController = TextEditingController();

  String? _idAnak;
  String? _namaAnak;
  DateTime? _tanggal;

  bool get _isEdit => widget.riwayat != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final r = widget.riwayat!;
      _idAnak = r.idAnak;
      _namaAnak = r.namaAnak;
      _namaVaksinController.text = r.namaVaksin;
      _faskesController.text = r.faskes;
      _catatanController.text = r.catatan ?? '';
      _tanggal = r.tanggalImunisasi;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riwayatController = Get.find<RiwayatController>();
    final anakController = Get.put(AnakController());

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Riwayat' : 'Tambah Riwayat Luar Faskes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Obx(() => ListView(
                children: [
                  const Text(
                    'Gunakan form ini untuk mencatat imunisasi yang sudah didapat anak '
                    'DI LUAR klinik Medikidz (misal sebelum pindah faskes).',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _idAnak,
                    decoration: const InputDecoration(labelText: 'Pilih Anak', border: OutlineInputBorder()),
                    items: anakController.anakList
                        .map((a) => DropdownMenuItem(value: a.id, child: Text(a.namaAnak)))
                        .toList(),
                    onChanged: (value) {
                      final anak = anakController.anakList.firstWhere((a) => a.id == value);
                      setState(() {
                        _idAnak = value;
                        _namaAnak = anak.namaAnak;
                      });
                    },
                    validator: (v) => (v == null) ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _namaVaksinController,
                    decoration: const InputDecoration(
                        labelText: 'Nama Vaksin', border: OutlineInputBorder(), hintText: 'Contoh: DPT dosis 2'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Tanggal Imunisasi', border: OutlineInputBorder()),
                      child: Text(
                        _tanggal == null ? 'Pilih tanggal' : '${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _faskesController,
                    decoration: const InputDecoration(
                        labelText: 'Faskes / Dokter', border: OutlineInputBorder(), hintText: 'Contoh: Puskesmas ABC'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Catatan (opsional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: riwayatController.isLoading.value ? null : _submit,
                      child: riwayatController.isLoading.value
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idAnak == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anak wajib dipilih.')));
      return;
    }
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal wajib diisi.')));
      return;
    }

    final riwayatController = Get.find<RiwayatController>();
    final riwayat = RiwayatImunisasi(
      id: widget.riwayat?.id,
      idAnak: _idAnak!,
      namaAnak: _namaAnak!,
      namaVaksin: _namaVaksinController.text.trim(),
      tanggalImunisasi: _tanggal!,
      faskes: _faskesController.text.trim(),
      catatan: _catatanController.text.trim(),
    );

    final success = _isEdit
        ? await riwayatController.updateData(widget.riwayat!.id!, riwayat)
        : await riwayatController.create(riwayat);

    if (success && mounted) Navigator.pop(context);
  }
}
