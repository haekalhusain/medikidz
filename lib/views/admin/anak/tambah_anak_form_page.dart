import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../controllers/pengguna_controller.dart';
import '../../../models/anak_model.dart';
import '../../../models/pengguna_model.dart';

/// Halaman Tambah Anak Baru. Admin WAJIB mengaitkan anak ke akun
/// orang tua (user) yang sudah registrasi, lewat dropdown "Pilih Akun
/// Orang Tua (User)" -- bukan input idUser manual.
class TambahAnakFormPage extends StatefulWidget {
  final String? idUser;
  final String? namaOrangTua;

  const TambahAnakFormPage({
    super.key,
    this.idUser,
    this.namaOrangTua,
  });

  @override
  State<TambahAnakFormPage> createState() => _TambahAnakFormPageState();
}

class _TambahAnakFormPageState extends State<TambahAnakFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaAnakController = TextEditingController();
  final _searchController = TextEditingController();

  DateTime? _tanggalLahir;
  String _jenisKelamin = 'laki-laki';
  Pengguna? _orangTuaTerpilih;
  String _searchQuery = '';

  @override
  void dispose() {
    _namaAnakController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final penggunaController = Get.put(PenggunaController());
    final anakController = Get.put(AnakController());

    if (widget.idUser != null && widget.namaOrangTua != null) {
      _orangTuaTerpilih = Pengguna(
        id: widget.idUser,
        nama: widget.namaOrangTua!,
        noHp: '',
        role: 'user',
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anak Baru')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Pilih Akun Orang Tua (User)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text(
                'Anak baru akan terkait langsung dengan akun user/pasien yang dipilih.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Cari nama / no. HP orang tua..',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (penggunaController.penggunaList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Belum ada akun user yang registrasi.', style: TextStyle(color: Colors.black54)),
                  );
                }

                final hasil = _searchQuery.isEmpty
                    ? penggunaController.penggunaList
                    : penggunaController.penggunaList
                        .where((p) =>
                            p.nama.toLowerCase().contains(_searchQuery) || p.noHp.contains(_searchQuery))
                        .toList();

                return DropdownButtonFormField<Pengguna>(
                  value: hasil.contains(_orangTuaTerpilih) ? _orangTuaTerpilih : null,
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  hint: const Text('-- Pilih Akun Orang Tua --'),
                  items: hasil
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text('${p.nama} (${p.noHp})', overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _orangTuaTerpilih = value),
                  validator: (value) => value == null ? 'Pilih akun orang tua terlebih dahulu' : null,
                );
              }),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              const Text('Data Anak', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
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

    final anak = Anak(
      idUser: _orangTuaTerpilih!.id!,
      namaAnak: _namaAnakController.text.trim(),
      tanggalLahir: _tanggalLahir!,
      jenisKelamin: _jenisKelamin,
    );

    final success = await anakController.create(anak);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anak baru berhasil ditambahkan.')));
      Navigator.pop(context);
    }
  }
}
