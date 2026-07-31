import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/artikel_controller.dart';
import '../../../controllers/pengguna_controller.dart';
import '../../../models/artikel_model.dart';
import '../../../models/konten_section_model.dart';
import '../../../services/image_upload_service.dart';

// Disesuaikan dengan kategori pada desain (Panduan, Fakta Medis, Tips Medis).
// Kalau butuh kategori lain, tinggal tambahkan ke list ini.
const _kategoriOptions = [
  'Panduan',
  'Fakta Medis',
  'Tips Medis',
];

const _statusOptions = [
  ('draft', 'Draft'),
  ('dipublikasi', 'Dipublikasi'),
  ('arsip', 'Arsip'),
];

class ArtikelFormPage extends StatefulWidget {
  final Artikel? artikel;
  const ArtikelFormPage({super.key, this.artikel});

  @override
  State<ArtikelFormPage> createState() => _ArtikelFormPageState();
}

class _ArtikelFormPageState extends State<ArtikelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _ringkasanController = TextEditingController();

  String? _kategori;
  String _status = 'draft';
  XFile? _gambarBaru;
  String? _gambarUrlLama;
  bool _isUploadingGambar = false;

  final List<_KontenControllerPair> _kontenControllers = [];

  bool get _isEdit => widget.artikel != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final a = widget.artikel!;
      _judulController.text = a.judul;
      _ringkasanController.text = a.ringkasan;
      _kategori = _kategoriOptions.contains(a.kategori) ? a.kategori : null;
      _status = a.status;
      _gambarUrlLama = a.gambarUrl;

      if (a.konten.isEmpty) {
        _kontenControllers.add(_KontenControllerPair());
      } else {
        for (final k in a.konten) {
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

  Future<void> _pickImage() async {
    final picked = await ImageUploadService.pickImage();
    if (picked != null) {
      setState(() => _gambarBaru = picked);
    }
  }

  Future<String?> _uploadGambarJikaAda() async {
    if (_gambarBaru == null) return _gambarUrlLama;

    setState(() => _isUploadingGambar = true);
    try {
      final url = await ImageUploadService.uploadImageToImgBB(_gambarBaru!);
      return url ?? _gambarUrlLama;
    } finally {
      if (mounted) setState(() => _isUploadingGambar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArtikelController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Artikel' : 'Tambah Artikel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('1. Informasi Dasar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              _RequiredLabel('Judul Artikel'),
              TextFormField(
                controller: _judulController,
                maxLength: 100,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              _RequiredLabel('Kategori'),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih Kategori'),
                items: _kategoriOptions.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (value) => setState(() => _kategori = value),
                validator: (v) => (v == null) ? 'Wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              _RequiredLabel('Status'),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s.$1, child: Text(s.$2)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 12),
              _RequiredLabel('Ringkasan Singkat'),
              TextFormField(
                controller: _ringkasanController,
                maxLength: 200,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 8),
              const Text('2. Gambar Sampul', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isUploadingGambar ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal.shade200),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal.withOpacity(0.03),
                  ),
                  child: _buildGambarPreview(),
                ),
              ),
              const SizedBox(height: 4),
              const Text('Format: JPG, PNG. Ukuran Maksimal: 2MB.',
                  style: TextStyle(fontSize: 11, color: Colors.black54)),

              const SizedBox(height: 20),
              const Text('3. Konten Artikel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
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
                      onPressed: (controller.isLoading.value || _isUploadingGambar) ? null : _submit,
                      child: (controller.isLoading.value || _isUploadingGambar)
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

  Widget _buildGambarPreview() {
    if (_gambarBaru != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(_gambarBaru!.path), fit: BoxFit.cover),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                child: const Text('Ubah', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ],
        ),
      );
    }
    if (_gambarUrlLama != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(_gambarUrlLama!, fit: BoxFit.cover, width: double.infinity),
      );
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, color: Colors.teal, size: 32),
          SizedBox(height: 8),
          Text('Upload Gambar Sampul', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('Format: JPG, PNG, Maks 2MB', style: TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  void _addKonten() => setState(() => _kontenControllers.add(_KontenControllerPair()));

  void _removeKonten(int index) {
    setState(() {
      _kontenControllers[index].subjudul.dispose();
      _kontenControllers[index].isi.dispose();
      _kontenControllers.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<ArtikelController>();
    final gambarUrl = await _uploadGambarJikaAda();

    // Penulis diambil otomatis dari akun admin yang sedang login,
    // BUKAN field yang diisi manual — supaya tidak bisa dipalsukan.
    // Saat edit, penulis asli dipertahankan (bukan diganti nama editor).
    String penulis = _isEdit ? widget.artikel!.penulis : '-';
    if (!_isEdit) {
      final pengguna = await PenggunaController().getCurrentPengguna();
      penulis = pengguna?.nama ?? '-';
    }

    final artikel = Artikel(
      judul: _judulController.text.trim(),
      kategori: _kategori!,
      ringkasan: _ringkasanController.text.trim(),
      gambarUrl: gambarUrl,
      konten: _kontenControllers
          .map((k) => KontenSection(subjudul: k.subjudul.text.trim(), isi: k.isi.text.trim()))
          .where((k) => k.subjudul.isNotEmpty || k.isi.isNotEmpty)
          .toList(),
      tanggalUpload: _isEdit ? widget.artikel!.tanggalUpload : DateTime.now(),
      status: _status,
      penulis: penulis,
    );

    final success = _isEdit
        ? await controller.updateData(widget.artikel!.id!, artikel)
        : await controller.create(artikel);
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
            Expanded(child: _RequiredLabel('Subjudul ${index + 1}')),
            if (onRemove != null)
              IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.red), onPressed: onRemove),
          ],
        ),
        TextFormField(
          controller: pair.subjudul,
          decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
        ),
        const SizedBox(height: 8),
        _RequiredLabel('Isi Artikel ${index + 1}'),
        TextFormField(
          controller: pair.isi,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
          validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
        ),
      ],
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String text;
  const _RequiredLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
          children: [
            TextSpan(text: text),
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
