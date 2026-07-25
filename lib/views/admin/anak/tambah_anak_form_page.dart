import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/anak_model.dart';

class TambahAnakFormPage extends StatefulWidget {
  final String idUser;
  final String namaOrangTua;

  const TambahAnakFormPage({super.key, required this.idUser, required this.namaOrangTua});

  @override
  State<TambahAnakFormPage> createState() => _TambahAnakFormPageState();
}

class _TambahAnakFormPageState extends State<TambahAnakFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnakController = TextEditingController();
  DateTime? _tanggalLahir;
  String _jenisKelamin = 'laki-laki';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anak Baru')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Orang tua: ${widget.namaOrangTua}', style: const TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal lahir wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final anak = Anak(
        idUser: widget.idUser,
        namaAnak: _namaAnakController.text.trim(),
        tanggalLahir: _tanggalLahir!,
        jenisKelamin: _jenisKelamin,
      );

      await FirebaseFirestore.instance.collection('tb_anak').add(anak.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anak baru berhasil ditambahkan.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
