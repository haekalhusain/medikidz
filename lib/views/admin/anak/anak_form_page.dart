import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/anak_model.dart';

/// Khusus EDIT data anak yang sudah ada. Untuk tambah anak BARU,
/// gunakan TambahAnakFormPage (ada dropdown pilih akun orang tua).
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

  // Color Palette Theme
  static const primaryTeal = Color(0xFF00A88F);
  static const backgroundColor = Color(0xFFF9FBFB);

  @override
  void initState() {
    super.initState();
    _namaAnakController = TextEditingController(text: widget.anak.namaAnak);
    _tanggalLahir = widget.anak.tanggalLahir;
    _jenisKelamin = widget.anak.jenisKelamin;
  }

  @override
  void dispose() {
    _namaAnakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AnakController>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(67),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: Center(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2F4EF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 38,
                        ),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: primaryTeal,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  title: const Text(
                    'Edit Data Anak',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Linear Gradient Line khas MediKidz
            Container(
              height: 2.0,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFA3D9CD),
                    Color(0xFFC5BC9B),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card Info Ringkas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F4EF).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryTeal.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.child_care_rounded,
                        color: primaryTeal,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Anak',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Perbarui rincian profil anak sesuai data resmi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Input 1: Nama Anak
              const Text(
                'Nama Lengkap Anak',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaAnakController,
                style: const TextStyle(fontSize: 14),
                decoration: _buildInputDecoration(
                  hintText: 'Masukkan nama anak',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama anak wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              // Input 2: Tanggal Lahir
              const Text(
                'Tanggal Lahir',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: _buildInputDecoration(
                    hintText: 'Pilih tanggal lahir',
                    prefixIcon: Icons.calendar_today_rounded,
                  ),
                  child: Text(
                    _tanggalLahir == null
                        ? 'Pilih tanggal'
                        : '${_tanggalLahir!.day.toString().padLeft(2, '0')}/${_tanggalLahir!.month.toString().padLeft(2, '0')}/${_tanggalLahir!.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: _tanggalLahir == null
                          ? Colors.black38
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Input 3: Jenis Kelamin (Desain Selection Card Custom)
              const Text(
                'Jenis Kelamin',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(
                      label: 'Laki-laki',
                      value: 'laki-laki',
                      icon: Icons.male_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderOption(
                      label: 'Perempuan',
                      value: 'perempuan',
                      icon: Icons.female_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Tombol Simpan
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: primaryTeal.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Pembantu untuk Pilihan Jenis Kelamin Kustom
  Widget _buildGenderOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _jenisKelamin == value;
    return InkWell(
      onTap: () => setState(() => _jenisKelamin = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryTeal.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryTeal : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? primaryTeal : Colors.black45,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryTeal : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Decoration Input Text
  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: primaryTeal, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryTeal, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2018),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryTeal,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
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
