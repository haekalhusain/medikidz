import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';
import '../../../models/konten_section_model.dart';
import 'package:flutter/services.dart';
import '../widgets/admin_header.dart';

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

  // Color Palette
  static const primaryTeal = Color(0xFF52C49C);
  static const lightTealBg = Color(0xFFE8F7F2);

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final v = widget.vaksin!;
      _namaController.text = v.namaVaksin;
      _stokController.text = v.jumlahStok.toString();
      _statusStok = v.statusStok;
      _kategoriVaksin = _kategoriOptions.contains(v.kategoriVaksin)
          ? v.kategoriVaksin
          : _kategoriOptions.first;

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
    _namaController.dispose();
    _stokController.dispose();
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
      backgroundColor: Colors.white,
      appBar: buildAdminTopBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header Tombol Kembali & Judul Form
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEdit ? 'Edit Vaksin' : 'Tambah Vaksin',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Input Nama Vaksin
              const _RequiredLabel('Nama Vaksin'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration(hintText: 'Contoh: Vaksin BCG'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Input Kategori Vaksin
              const _RequiredLabel('Kategori Vaksin'),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _kategoriVaksin,
                isExpanded: true,
                decoration: _inputDecoration(),
                items: _kategoriOptions
                    .map((k) => DropdownMenuItem(
                          value: k,
                          child: Text(
                            k,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _kategoriVaksin = value!),
              ),
              const SizedBox(height: 16),

              // Row Stok & Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _RequiredLabel('Stok'),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _stokController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _inputDecoration(hintText: 'Contoh: 16'),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Wajib diisi';
                            final parsedValue = int.tryParse(v);
                            if (parsedValue == null) return 'Harus angka';
                            if (parsedValue < 0) return 'Stok tidak boleh minus';
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
                        const _RequiredLabel('Status'),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _statusStok,
                          decoration: _inputDecoration(),
                          items: const [
                            DropdownMenuItem(
                                value: 'tersedia',
                                child: Text('Tersedia', style: TextStyle(fontSize: 14))),
                            DropdownMenuItem(
                                value: 'menipis',
                                child: Text('Stok Menipis', style: TextStyle(fontSize: 14))),
                            DropdownMenuItem(
                                value: 'kosong',
                                child: Text('Kosong', style: TextStyle(fontSize: 14))),
                          ],
                          onChanged: (value) =>
                              setState(() => _statusStok = value!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Informasi Label
              const _RequiredLabel('Informasi'),
              const SizedBox(height: 8),

              // Container Abu-abu untuk Blok Informasi
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < _kontenControllers.length; i++) ...[
                      _KontenBlock(
                        index: i,
                        pair: _kontenControllers[i],
                        onRemove: _kontenControllers.length > 1
                            ? () => _removeKonten(i)
                            : null,
                      ),
                      if (i != _kontenControllers.length - 1)
                        const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Tambah Konten Artikel
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryTeal,
                    side: const BorderSide(color: primaryTeal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  onPressed: _addKonten,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Tambah Konten Artikel',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed:
                          controller.isLoading.value ? null : _submit,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      fillColor: Colors.white,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryTeal),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
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
          .map((k) => KontenSection(
              subjudul: k.subjudul.text.trim(), isi: k.isi.text.trim()))
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

  const _KontenBlock({
    required this.index,
    required this.pair,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _RequiredLabel('Subjudul ${index + 1}'),
            ),
            if (onRemove != null)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Hapus blok ini',
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: pair.subjudul,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF52C49C)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _RequiredLabel('Isi Artikel ${index + 1}'),
        const SizedBox(height: 4),
        TextFormField(
          controller: pair.isi,
          maxLines: 3,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF52C49C)),
            ),
          ),
        ),
      ],
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool bold;

  const _RequiredLabel(this.text, {this.fontSize = 13, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black87,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
          children: [
            TextSpan(text: text),
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
