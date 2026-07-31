import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../controllers/anak_controller.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/jadwal_model.dart';
import '../../../models/anak_model.dart';

class JadwalFormPage extends StatefulWidget {
  final JadwalImunisasi? jadwal; // ada isi = mode edit
  final Anak? anakTerpilih; // dipakai kalau dibuka dari halaman detail anak, biar tidak perlu pilih ulang

  const JadwalFormPage({super.key, this.jadwal, this.anakTerpilih});

  @override
  State<JadwalFormPage> createState() => _JadwalFormPageState();
}

class _JadwalFormPageState extends State<JadwalFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _urutanDosisController = TextEditingController();

  String? _idAnak;
  String? _namaAnak;
  String? _idVaksin;
  String? _namaVaksin;
  DateTime? _tanggal;
  String _status = 'belum imunisasi';

  bool get _isEdit => widget.jadwal != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final j = widget.jadwal!;
      _idAnak = j.idAnak;
      _namaAnak = j.namaAnak;
      _idVaksin = j.idVaksin;
      _namaVaksin = j.namaVaksin;
      _tanggal = j.tanggalImunisasi;
      _status = j.status;
      _urutanDosisController.text = j.urutanDosis?.toString() ?? '';
    } else if (widget.anakTerpilih != null) {
      _idAnak = widget.anakTerpilih!.id;
      _namaAnak = widget.anakTerpilih!.namaAnak;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jadwalController = Get.find<JadwalController>();
    final anakController = Get.put(AnakController());
    final vaksinController = Get.put(VaksinController());

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Jadwal' : 'Tambah Jadwal')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Obx(() => ListView(
                children: [
                  DropdownButtonFormField<String>(
                    value: _idAnak,
                    decoration: const InputDecoration(labelText: 'Pilih Anak', border: OutlineInputBorder()),
                    items: anakController.anakList
                        .map((a) => DropdownMenuItem(value: a.id, child: Text(a.namaAnak)))
                        .toList(),
                    onChanged: widget.anakTerpilih != null
                        ? null // kalau sudah dibuka dari halaman detail anak, tidak perlu diganti
                        : (value) {
                            final anak = anakController.anakList.firstWhere((a) => a.id == value);
                            setState(() {
                              _idAnak = value;
                              _namaAnak = anak.namaAnak;
                            });
                          },
                    validator: (v) => (v == null) ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _idVaksin,
                    decoration: const InputDecoration(labelText: 'Pilih Vaksin', border: OutlineInputBorder()),
                    items: vaksinController.vaksinList
                        .map((v) => DropdownMenuItem(value: v.id, child: Text(v.namaVaksin)))
                        .toList(),
                    onChanged: (value) {
                      final vaksin = vaksinController.vaksinList.firstWhere((v) => v.id == value);
                      setState(() {
                        _idVaksin = value;
                        _namaVaksin = vaksin.namaVaksin;
                      });
                    },
                    validator: (v) => (v == null) ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urutanDosisController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Urutan Dosis (opsional)', border: OutlineInputBorder(), hintText: 'Contoh: 1'),
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
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'belum imunisasi', child: Text('Belum Imunisasi')),
                      DropdownMenuItem(value: 'sudah imunisasi', child: Text('Sudah Imunisasi')),
                    ],
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: jadwalController.isLoading.value ? null : _submit,
                      child: jadwalController.isLoading.value
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
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _submit() async {
    // Validasi manual untuk field yang bukan TextFormField (dropdown & date).
    // Kalau tidak valid, TETAP di form ini (tidak pop), sesuai requirement.
    if (!_formKey.currentState!.validate()) return;
    if (_idAnak == null || _idVaksin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anak dan vaksin wajib dipilih.')),
      );
      return;
    }
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal imunisasi wajib diisi.')),
      );
      return;
    }

    final jadwalController = Get.find<JadwalController>();
    final jadwal = JadwalImunisasi(
      id: widget.jadwal?.id,
      idAnak: _idAnak!,
      idVaksin: _idVaksin!,
      tanggalImunisasi: _tanggal!,
      status: _status,
      namaAnak: _namaAnak,
      namaVaksin: _namaVaksin,
      urutanDosis: _urutanDosisController.text.isEmpty ? null : int.tryParse(_urutanDosisController.text),
    );

    final success = _isEdit
        ? await jadwalController.updateData(widget.jadwal!.id!, jadwal)
        : await jadwalController.create(jadwal);

    if (success && mounted) Navigator.pop(context);
  }
}
