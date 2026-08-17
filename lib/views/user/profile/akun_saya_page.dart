import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/anak_model.dart';
import '../../../models/notifikasi_model.dart';
import '../../../models/pengguna_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notifikasi_service.dart';
import '../../../utils/date_formatter.dart';
import '../anak/tambah_anak_user_page.dart';
import '../widgets/user_header.dart';

class AkunSayaPage extends StatefulWidget {
  const AkunSayaPage({super.key});

  @override
  State<AkunSayaPage> createState() => _AkunSayaPageState();
}

class _AkunSayaPageState extends State<AkunSayaPage> {
  int _tabIndex = 0; // 0 = Data Personal, 1 = Data Anak

  static const Color primaryTeal = Color(0xFF2FA28D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(context), // Menggunakan AppBar/Header dari user_header.dart
      body: SafeArea(
        child: Column(
          children: [
            // Custom Back Button & Judul Halaman
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Akun Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPillToggle(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _tabIndex == 0
                          ? const _DataPersonalTab()
                          : const _DataAnakTab(),
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

  Widget _buildPillToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryTeal, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(child: _pillButton('Data personal', 0)),
          Expanded(child: _pillButton('Data Anak', 1)),
        ],
      ),
    );
  }

  Widget _pillButton(String label, int index) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : primaryTeal,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _DataPersonalTab extends StatefulWidget {
  const _DataPersonalTab();

  @override
  State<_DataPersonalTab> createState() => _DataPersonalTabState();
}

class _DataPersonalTabState extends State<_DataPersonalTab> {
  final _namaController = TextEditingController();
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _alamatController = TextEditingController();

  static const Color primaryTeal = Color(0xFF2FA28D);

  final _penggunaService = FirestoreService<Pengguna>(
    collectionPath: 'tb_pengguna',
    fromJson: Pengguna.fromJson,
    toJson: (p) => p.toJson(),
  );

  bool _isLoading = true;
  bool _isSaving = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _uid = AuthService().currentUser?.uid;
    if (_uid == null) return;
    final pengguna = await _penggunaService.getById(_uid!);
    if (pengguna != null) {
      _namaController.text = pengguna.nama;
      _noHpController.text = pengguna.noHp;
      _emailController.text = pengguna.email ?? '';
      _alamatController.text = pengguna.alamat ?? '';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    if (_uid == null) return;
    setState(() => _isSaving = true);

    final updated = Pengguna(
      id: _uid,
      nama: _namaController.text.trim(),
      noHp: _noHpController.text.trim(),
      role: 'user',
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      alamat: _alamatController.text.trim().isEmpty
          ? null
          : _alamatController.text.trim(),
    );

    try {
      await _penggunaService.update(_uid!, updated);
      await NotifikasiService().createForUser(
        _uid!,
        Notifikasi(
          uid: _uid!,
          judul: 'Pembaruan Data Akun',
          pesan: 'Data personal kamu berhasil diperbarui.',
          kategori: 'akun',
          waktu: DateTime.now(),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data personal disimpan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryTeal),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const Text(
          'Nama',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _FieldBox(controller: _namaController),
        const SizedBox(height: 18),
        const Text(
          'No.Telp',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _FieldBox(
          controller: _noHpController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 18),
        const Text(
          'E-Mail',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _FieldBox(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        const Text(
          'Alamat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _FieldBox(controller: _alamatController),
        const SizedBox(height: 28),
        SizedBox(
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
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Selesai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _DataAnakTab extends StatefulWidget {
  const _DataAnakTab();

  @override
  State<_DataAnakTab> createState() => _DataAnakTabState();
}

class _DataAnakTabState extends State<_DataAnakTab> {
  final _namaAnakController = TextEditingController();
  final _nikController = TextEditingController();
  DateTime? _tanggalLahir;
  String _jenisKelamin = 'laki-laki';

  int _selectedIndex = 0;
  String? _loadedForAnakId;
  bool _isSaving = false;

  static const Color primaryTeal = Color(0xFF2FA28D);

  @override
  void dispose() {
    _namaAnakController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  void _populateFrom(Anak anak) {
    if (_loadedForAnakId == anak.id) return;
    _namaAnakController.text = anak.namaAnak;
    _nikController.text = anak.nik ?? '';
    _tanggalLahir = anak.tanggalLahir;
    _jenisKelamin = anak.jenisKelamin;
    _loadedForAnakId = anak.id;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2020),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tanggalLahir = picked);
  }

  Future<void> _submit(AnakController controller, Anak anak) async {
    setState(() => _isSaving = true);

    final updated = Anak(
      id: anak.id,
      idUser: anak.idUser,
      namaAnak: _namaAnakController.text.trim(),
      tanggalLahir: _tanggalLahir ?? anak.tanggalLahir,
      jenisKelamin: _jenisKelamin,
      nik: _nikController.text.trim().isEmpty
          ? null
          : _nikController.text.trim(),
    );

    final success = await controller.updateData(anak.id!, updated);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data anak disimpan.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnakController());
    final uid = AuthService().currentUser?.uid;

    return Obx(() {
      final anakSaya = controller.anakList
          .where((a) => a.idUser == uid)
          .toList();

      if (anakSaya.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum ada data anak.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryTeal,
                  side: const BorderSide(color: primaryTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TambahAnakUserPage()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Data Anak'),
              ),
            ],
          ),
        );
      }

      if (_selectedIndex >= anakSaya.length) _selectedIndex = 0;
      final anak = anakSaya[_selectedIndex];
      _populateFrom(anak);

      return ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Profil Anak ${_selectedIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              
              // Dropdown disesuaikan dengan Gambar 2
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedIndex,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    selectedItemBuilder: (BuildContext context) {
                      return anakSaya.map<Widget>((Anak item) {
                        final nama = item.namaAnak.split(' ').first;
                        return Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    items: List.generate(
                      anakSaya.length,
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(
                          anakSaya[i].namaAnak.length > 15
                              ? '${anakSaya[i].namaAnak.substring(0, 15)}...'
                              : anakSaya[i].namaAnak,
                          style: const TextStyle(
                            color: primaryTeal,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _selectedIndex = value ?? 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Nama Anak',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _FieldBox(controller: _namaAnakController),
          const SizedBox(height: 18),
          const Text(
            'Tanggal Lahir',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Text(
                _tanggalLahir == null
                    ? 'Pilih tanggal'
                    : formatTanggal(_tanggalLahir!),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Jenis Kelamin',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _jenisKelamin,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'laki-laki',
                    child: Row(
                      children: [
                        Icon(Icons.male, color: Colors.lightBlue, size: 20),
                        SizedBox(width: 8),
                        Text('Laki-laki', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'perempuan',
                    child: Row(
                      children: [
                        Icon(Icons.female, color: Colors.pinkAccent, size: 20),
                        SizedBox(width: 8),
                        Text('Perempuan', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _jenisKelamin = value ?? 'laki-laki'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'NIK',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _FieldBox(
            controller: _nikController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryTeal,
                side: const BorderSide(color: primaryTeal, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TambahAnakUserPage()),
              ),
              child: const Text(
                '+Tambah Data Anak',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
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
              onPressed: _isSaving ? null : () => _submit(controller, anak),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Selesai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    });
  }
}

class _FieldBox extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _FieldBox({required this.controller, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF2FA28D)),
        ),
      ),
    );
  }
}