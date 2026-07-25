import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';

class VaksinFormPage extends StatefulWidget {
  final Vaksin? vaksin;
  const VaksinFormPage({super.key, this.vaksin});

  @override
  State<VaksinFormPage> createState() => _VaksinFormPageState();
}

class _VaksinFormPageState extends State<VaksinFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usiaController = TextEditingController();
  final _stokController = TextEditingController();
  String _statusStok = 'tersedia';

  bool get _isEdit => widget.vaksin != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _namaController.text = widget.vaksin!.namaVaksin;
      _usiaController.text = widget.vaksin!.usiaImunisasi;
      _stokController.text = widget.vaksin!.jumlahStok.toString();
      _statusStok = widget.vaksin!.statusStok;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VaksinController>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Vaksin' : 'Tambah Vaksin')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Vaksin', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usiaController,
                decoration: const InputDecoration(
                    labelText: 'Usia Imunisasi (contoh: 0-1 bulan)', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah Stok', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus berupa angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _statusStok,
                decoration: const InputDecoration(labelText: 'Status Stok', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'menipis', child: Text('Menipis')),
                  DropdownMenuItem(value: 'habis', child: Text('Habis')),
                ],
                onChanged: (value) => setState(() => _statusStok = value!),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _submit,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Vaksin'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = Get.find<VaksinController>();
    final vaksin = Vaksin(
      namaVaksin: _namaController.text.trim(),
      usiaImunisasi: _usiaController.text.trim(),
      jumlahStok: int.parse(_stokController.text),
      statusStok: _statusStok,
    );
    final success = _isEdit
        ? await controller.updateData(widget.vaksin!.id!, vaksin)
        : await controller.create(vaksin);
    if (success && mounted) Navigator.pop(context);
  }
}
