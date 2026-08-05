import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/auth_service.dart';
import '../../../utils/date_formatter.dart';

/// Form tambah anak dari sisi user/orang tua sendiri. idUser otomatis
/// dipakai dari akun yang sedang login -- tidak perlu pilih akun lagi
/// (beda dengan alur admin yang butuh dropdown pilih orang tua).
class TambahAnakUserPage extends StatefulWidget {
  const TambahAnakUserPage({super.key});

  @override
  State<TambahAnakUserPage> createState() => _TambahAnakUserPageState();
}

class _TambahAnakUserPageState extends State<TambahAnakUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnakController = TextEditingController();
  DateTime? _tanggalLahir;
  String _jenisKelamin = 'laki-laki';

  @override
  void dispose() {
    _namaAnakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anakController = Get.put(AnakController());

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anak')),
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
                        : formatTanggal(_tanggalLahir!),
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
                      onPressed: anakController.isLoading.value ? null : () => _submit(anakController),
                      child: anakController.isLoading.value
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Simpan'),
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
      initialDate: DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  Future<void> _submit(AnakController anakController) async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal lahir wajib diisi')));
      return;
    }

    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;

    final anak = Anak(
      idUser: uid,
      namaAnak: _namaAnakController.text.trim(),
      tanggalLahir: _tanggalLahir!,
      jenisKelamin: _jenisKelamin,
    );

    final success = await anakController.create(anak);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anak berhasil ditambahkan.')));
      Navigator.pop(context);
    }
  }
}
