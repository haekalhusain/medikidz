import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';
import '../../../models/konten_section_model.dart';

const _kategoriOptions = [
  'Program Pemerintahan (Imunisasi Rutin Wajib)',
  'Program Mandiri (Pilihan)',
];

class VaksinFormPage extends StatefulWidget {
  final Vaksin? vaksin;
  const VaksinFormPage({super.key, this.vaksin});

  @override
  State<VaksinFormPage> createState() => _VaksinFormPageState();
}

class _VaksinFormPageState extends State<VaksinFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _stokController = TextEditingController();

  String _kategoriVaksin = _kategoriOptions.first;
  String _statusStok = 'tersedia';

  // Tiap blok konten punya 2 controller: subjudul & isi.
  final List<_KontenControllerPair> _kontenControllers = [];

  bool get _isEdit => widget.vaksin != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final v = widget.vaksin!;
      _namaController.text = v.namaVaksin;
      _stokController.text = v.jumlahStok.toString();
      _statusStok = v.statusStok;
      _kategoriVaksin = _kategoriOptions.contains(v.kategoriVaksin) ? v.kategoriVaksin : _kategoriOptions.first;

      if (v.informasi.isEmpty) {
        _kontenControllers.add(_KontenControllerPair());
      } else {
        for (final k in v.informasi) {
          _kontenControllers.add(_KontenControllerPair()
            ..subjudul.text = k.subjudul
            ..isi.text = k.isi);
        }
      }
    } else {
      _kontenControllers.add(_KontenControllerPair());
    }
  }

  @override
  void dispose() {
    for (final k in _kontenControllers) {
      k.subjudul.dispose();
      k.isi.dispose();
    }
    super.dispose();
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
          child: ListView(
            children: [
              _RequiredLabel('Nama Vaksin'),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: Vaksin BCG'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _RequiredLabel('Kategori Vaksin'),
              DropdownButtonFormField<String>(
                value: _kategoriVaksin,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _kategoriOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text(k, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (value) => setState(() => _kategoriVaksin = value!),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RequiredLabel('Stok'),
                        TextFormField(
                          controller: _stokController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: 16'),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            if (int.tryParse(v) == null) return 'Harus angka';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RequiredLabel('Status'),
                        DropdownButtonFormField<String>(
                          value: _statusStok,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'tersedia', child: Text('Tersedia')),
                            DropdownMenuItem(value: 'menipis', child: Text('Stok Menipis')),
                            DropdownMenuItem(value: 'kosong', child: Text('Kosong')),
                          ],
                          onChanged: (value) => setState(() => _statusStok = value!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _OptionalLabel('Informasi (opsional)', fontSize: 15, bold: true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _kontenControllers.length; i++) ...[
                      _KontenBlock(
                        index: i,
                        pair: _kontenControllers[i],
                        onRemove: _kontenControllers.length > 1 ? () => _removeKonten(i) : null,
                      ),
                      if (i != _kontenControllers.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _addKonten,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Konten Artikel'),
                ),
              ),

              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _submit,
                      child: controller.isLoading.value
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

  void _addKonten() {
    setState(() => _kontenControllers.add(_KontenControllerPair()));
  }

  void _removeKonten(int index) {
    setState(() {
      _kontenControllers[index].subjudul.dispose();
      _kontenControllers[index].isi.dispose();
      _kontenControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<VaksinController>();
    final vaksin = Vaksin(
      namaVaksin: _namaController.text.trim(),
      kategoriVaksin: _kategoriVaksin,
      jumlahStok: int.parse(_stokController.text),
      statusStok: _statusStok,
      informasi: _kontenControllers
          .map((k) => KontenSection(subjudul: k.subjudul.text.trim(), isi: k.isi.text.trim()))
          .where((k) => k.subjudul.isNotEmpty || k.isi.isNotEmpty)
          .toList(),
    );

    final success = _isEdit
        ? await controller.updateData(widget.vaksin!.id!, vaksin)
        : await controller.create(vaksin);
    if (success && mounted) Navigator.pop(context);
  }
}

class _KontenControllerPair {
  final subjudul = TextEditingController();
  final isi = TextEditingController();
}

class _KontenBlock extends StatelessWidget {
  final int index;
  final _KontenControllerPair pair;
  final VoidCallback? onRemove;

  const _KontenBlock({required this.index, required this.pair, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _OptionalLabel('Subjudul ${index + 1}'),
            ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Hapus blok ini',
              ),
          ],
        ),
        TextFormField(
          controller: pair.subjudul,
          decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
        ),
        const SizedBox(height: 8),
        _OptionalLabel('Isi Artikel ${index + 1}'),
        TextFormField(
          controller: pair.isi,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
        ),
      ],
    );
  }
}

class _OptionalLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool bold;
  const _OptionalLabel(this.text, {this.fontSize = 13, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool bold;
  // ignore: unused_element_parameter
  const _RequiredLabel(this.text, {this.fontSize = 13, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black87,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
          children: [
            TextSpan(text: text),
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
