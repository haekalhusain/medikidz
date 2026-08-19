import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/artikel_controller.dart';
import '../../../controllers/pengguna_controller.dart';
import '../../../models/artikel_model.dart';
import '../../../models/konten_section_model.dart';
import '../../../services/image_upload_service.dart';

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

  // Color Palette
  static const primaryTeal = Color(0xFF00A884);
  static const lightTealBg = Color(0xFFE8F7F2);
  static const bgInput = Color(0xFFF8FAFC);
  static const borderInput = Color(0xFFE2E8F0);

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
    _judulController.dispose();
    _ringkasanController.dispose();
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
      if (url == null && mounted) {
        Get.snackbar(
          'Upload gambar gagal',
          'Gambar belum masuk ImgBB. Periksa koneksi lalu coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return url ?? _gambarUrlLama;
    } finally {
      if (mounted) setState(() => _isUploadingGambar = false);
    }
  }

  // Common Input Decoration
  InputDecoration _customInputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderInput),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArtikelController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Edit Artikel' : 'Tambah Artikel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Lengkapi data artikel di bawah ini',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // --- SECTION 1: INFORMASI DASAR ---
            _buildSectionHeader('1. Informasi Dasar', Icons.article_outlined),
            const SizedBox(height: 12),

            _RequiredLabel('Judul Artikel'),
            TextFormField(
              controller: _judulController,
              maxLength: 100,
              style: const TextStyle(fontSize: 13),
              decoration: _customInputDecoration(hintText: 'Masukkan judul artikel...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RequiredLabel('Kategori'),
                      DropdownButtonFormField<String>(
                        value: _kategori,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        decoration: _customInputDecoration(hintText: 'Pilih Kategori'),
                        items: _kategoriOptions
                            .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                            .toList(),
                        onChanged: (value) => setState(() => _kategori = value),
                        validator: (v) => (v == null) ? 'Wajib dipilih' : null,
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
                        value: _status,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        decoration: _customInputDecoration(hintText: 'Pilih Status'),
                        items: _statusOptions
                            .map((s) => DropdownMenuItem(value: s.$1, child: Text(s.$2)))
                            .toList(),
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _RequiredLabel('Ringkasan Singkat'),
            TextFormField(
              controller: _ringkasanController,
              maxLength: 200,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: _customInputDecoration(hintText: 'Tuliskan ringkasan singkat artikel...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ringkasan wajib diisi' : null,
            ),

            const SizedBox(height: 20),

            // --- SECTION 2: GAMBAR SAMPUL ---
            _buildSectionHeader('2. Gambar Sampul', Icons.image_outlined),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isUploadingGambar ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: lightTealBg.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryTeal.withOpacity(0.4), width: 1.5),
                ),
                child: _buildGambarPreview(),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '  * Format: JPG, PNG. Ukuran Maksimal: 2MB.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 24),

            // --- SECTION 3: KONTEN ARTIKEL ---
            _buildSectionHeader('3. Konten Artikel', Icons.segment_rounded),
            const SizedBox(height: 12),

            Column(
              children: [
                for (int i = 0; i < _kontenControllers.length; i++) ...[
                  _KontenBlock(
                    index: i,
                    pair: _kontenControllers[i],
                    inputDecoration: _customInputDecoration,
                    onRemove: _kontenControllers.length > 1 ? () => _removeKonten(i) : null,
                  ),
                  if (i != _kontenControllers.length - 1) const SizedBox(height: 14),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Tombol Tambah Konten
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _addKonten,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: lightTealBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_circle_outline, size: 18, color: primaryTeal),
                      SizedBox(width: 6),
                      Text(
                        'Tambah Section Konten',
                        style: TextStyle(
                          color: primaryTeal,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- SUBMIT BUTTON ---
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (controller.isLoading.value || _isUploadingGambar)
                        ? null
                        : _submit,
                    child: (controller.isLoading.value || _isUploadingGambar)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Artikel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildGambarPreview() {
    if (_gambarBaru != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(_gambarBaru!.path), fit: BoxFit.cover),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Ganti Foto',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_gambarUrlLama != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _gambarUrlLama!,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, color: primaryTeal, size: 36),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Ubah Gambar',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.cloud_upload_outlined, color: primaryTeal, size: 36),
        SizedBox(height: 6),
        Text(
          'Upload Gambar Sampul',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        SizedBox(height: 2),
        Text(
          'Ketuk di sini untuk memilih gambar',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
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
    if (_gambarBaru != null && gambarUrl == _gambarUrlLama) return;

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
  final InputDecoration Function({required String hintText, Widget? suffixIcon}) inputDecoration;
  final VoidCallback? onRemove;

  const _KontenBlock({
    required this.index,
    required this.pair,
    required this.inputDecoration,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A884).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Bagian #${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A884),
                  ),
                ),
              ),
              if (onRemove != null)
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _RequiredLabel('Subjudul ${index + 1}'),
          TextFormField(
            controller: pair.subjudul,
            style: const TextStyle(fontSize: 13),
            decoration: inputDecoration(hintText: 'Masukkan subjudul bagian...'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Subjudul wajib diisi' : null,
          ),
          const SizedBox(height: 10),
          _RequiredLabel('Isi Artikel ${index + 1}'),
          TextFormField(
            controller: pair.isi,
            maxLines: 4,
            style: const TextStyle(fontSize: 13),
            decoration: inputDecoration(hintText: 'Tulis paragraf penjelasan...'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi artikel wajib diisi' : null,
          ),
        ],
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final String text;
  const _RequiredLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: text),
            const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
