import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../controllers/pengguna_controller.dart';
import '../../../models/anak_model.dart';
import '../../../models/pengguna_model.dart';
import '../profile/profile_page.dart';

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
  void initState() {
    super.initState();
    if (widget.idUser != null && widget.namaOrangTua != null) {
      _orangTuaTerpilih = Pengguna(
        id: widget.idUser,
        nama: widget.namaOrangTua!,
        noHp: '',
        role: 'user',
      );
    }
  }

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ATAS (LOGO & PROFIL) ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 32,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.medical_services,
                          color: Color(0xFF359D89),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Image.asset(
                        'assets/logo2.png',
                        height: 14,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F4F1),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF359D89),
                              size: 22,
                            ),
                            Positioned(
                              top: 8,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const ProfilePage());
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6F4F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF359D89),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

            // --- TITLE & ACTION BACK ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Anak Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Kaitkan anak ke akun orang tua yang terdaftar',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- FORM CONTENT ---
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // SECTION 1: SELEKSI ORANG TUA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.family_restroom_rounded, color: Color(0xFF359D89), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Akun Orang Tua (User)',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Anak baru akan terkait langsung dengan akun user/pasien yang dipilih.',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 14),

                          // Search Orang Tua
                          TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Cari nama / no. HP orang tua..',
                              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF359D89), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Dropdown Orang Tua
                          Obx(() {
                            if (penggunaController.penggunaList.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Belum ada akun user yang registrasi.',
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ),
                              );
                            }

                            final hasil = _searchQuery.isEmpty
                                ? penggunaController.penggunaList
                                : penggunaController.penggunaList
                                    .where((p) =>
                                        p.nama.toLowerCase().contains(_searchQuery) ||
                                        p.noHp.contains(_searchQuery))
                                    .toList();

                            return DropdownButtonFormField<Pengguna>(
                              value: hasil.contains(_orangTuaTerpilih) ? _orangTuaTerpilih : null,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF359D89)),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: const Color(0xFFFAFAFA),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF359D89), width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.redAccent),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                ),
                              ),
                              hint: const Text(
                                '-- Pilih Akun Orang Tua --',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              items: hasil
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(
                                          '${p.nama} (${p.noHp})',
                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) => setState(() => _orangTuaTerpilih = value),
                              validator: (value) =>
                                  value == null ? 'Pilih akun orang tua terlebih dahulu' : null,
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 2: DATA ANAK
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.child_care_rounded, color: Color(0xFF359D89), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Data Anak',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nama Anak
                          TextFormField(
                            controller: _namaAnakController,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap Anak',
                              labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF359D89), size: 20),
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF359D89), width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama anak wajib diisi' : null,
                          ),
                          const SizedBox(height: 14),

                          // Tanggal Lahir
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, color: Color(0xFF359D89), size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tanggal Lahir',
                                          style: TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _tanggalLahir == null
                                              ? 'Pilih tanggal lahir'
                                              : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: _tanggalLahir == null ? FontWeight.normal : FontWeight.w600,
                                            color: _tanggalLahir == null ? Colors.grey.shade600 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.edit_calendar_rounded, color: Colors.grey, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Jenis Kelamin
                          DropdownButtonFormField<String>(
                            value: _jenisKelamin,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF359D89)),
                            decoration: InputDecoration(
                              labelText: 'Jenis Kelamin',
                              labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: Icon(
                                _jenisKelamin == 'laki-laki' ? Icons.male_rounded : Icons.female_rounded,
                                color: const Color(0xFF359D89),
                                size: 20,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF359D89), width: 1.5),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'laki-laki',
                                child: Text('Laki-laki', style: TextStyle(fontSize: 13)),
                              ),
                              DropdownMenuItem(
                                value: 'perempuan',
                                child: Text('Perempuan', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                            onChanged: (value) => setState(() => _jenisKelamin = value!),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TOMBOL SUBMIT
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: anakController.isLoading.value ? null : () => _submit(anakController),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF359D89),
                            disabledBackgroundColor: const Color(0xFF359D89).withOpacity(0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                                  'Simpan Data Anak',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF359D89),
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

  Future<void> _submit(AnakController anakController) async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal lahir wajib diisi'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anak baru berhasil ditambahkan.'),
          backgroundColor: Color(0xFF359D89),
        ),
      );
      Navigator.pop(context);
    }
  }
}