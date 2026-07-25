import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/anak_model.dart';

/// Khusus EDIT data anak yang sudah ada. Untuk tambah anak BARU,
/// gunakan alur CariAkunPage -> TambahAnakFormPage.
class AnakFormPage extends StatefulWidget {
  final Anak anak;
  const AnakFormPage({super.key, required this.anak});

  @override
  State<AnakFormPage> createState() => _AnakFormPageState();
}

class _AnakFormPageState extends State<AnakFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaAnakController;
  DateTime? _tanggalLahir;
  late String _jenisKelamin;

  @override
  void initState() {
    super.initState();
    _namaAnakController = TextEditingController(text: widget.anak.namaAnak);
    _tanggalLahir = widget.anak.tanggalLahir;
    _jenisKelamin = widget.anak.jenisKelamin;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnakController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Data Anak')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaAnakController,
                decoration: const InputDecoration(labelText: 'Nama Anak', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal Lahir', border: OutlineInputBorder()),
                  child: Text(
                    _tanggalLahir == null
                        ? 'Pilih tanggal'
                        : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                decoration: const InputDecoration(labelText: 'Jenis Kelamin', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'perempuan', child: Text('Perempuan')),
                ],
                onChanged: (value) => setState(() => _jenisKelamin = value!),
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _submit,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Simpan Perubahan'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2018),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      Get.snackbar('Perhatian', 'Tanggal lahir wajib diisi');
      return;
    }

    final controller = Get.find<AnakController>();
    final updated = Anak(
      id: widget.anak.id,
      idUser: widget.anak.idUser,
      namaAnak: _namaAnakController.text.trim(),
      tanggalLahir: _tanggalLahir!,
      jenisKelamin: _jenisKelamin,
    );

    final success = await controller.updateData(widget.anak.id!, updated);
    if (success && mounted) Navigator.pop(context);
  }
}
