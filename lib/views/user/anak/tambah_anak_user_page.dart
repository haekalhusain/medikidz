import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/auth_service.dart';
import '../../../utils/date_formatter.dart';
import '../widgets/user_header.dart';

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
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(
        context,
        showBackButton: true,
        hideNotification: true,
        hideProfileIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A884),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Tambah Profil Anak Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF17394D),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Isi data anak agar informasi kesehatan dan jadwal imunisasi tercatat rapi.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B636E),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Card wrapper for form
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _namaAnakController,
                      label: 'Nama Anak',
                    ),
                    const SizedBox(height: 14),
                    _buildDatePicker(context),
                    const SizedBox(height: 14),
                    _buildGenderDropdown(),
                    const SizedBox(height: 20),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A884),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: anakController.isLoading.value
                              ? null
                              : () => _submit(anakController),
                          child: anakController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Simpan Profil Anak',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: _pickDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tanggalLahir == null
                  ? 'Pilih tanggal'
                  : formatTanggal(_tanggalLahir!),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_month, color: Color(0xFF00A884)),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _jenisKelamin,
      decoration: InputDecoration(
        labelText: 'Jenis Kelamin',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      items: const [
        DropdownMenuItem(value: 'laki-laki', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'perempuan', child: Text('Perempuan')),
      ],
      onChanged: (value) => setState(() => _jenisKelamin = value!),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir wajib diisi')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil anak berhasil ditambahkan.')),
      );
      Navigator.pop(context);
    }
  }
}
