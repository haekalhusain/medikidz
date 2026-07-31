import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/anak_model.dart';
import '../../../models/pengguna_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../anak/tambah_anak_user_page.dart';

class AkunSayaPage extends StatefulWidget {
  const AkunSayaPage({super.key});

  @override
  State<AkunSayaPage> createState() => _AkunSayaPageState();
}

class _AkunSayaPageState extends State<AkunSayaPage> {
  int _tabIndex = 0; // 0 = Data Personal, 1 = Data Anak

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun Saya')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPillToggle(),
            const SizedBox(height: 20),
            Expanded(
              child: _tabIndex == 0 ? const _DataPersonalTab() : const _DataAnakTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillToggle() {
    return Row(
      children: [
        Expanded(child: _pillButton('Data personal', 0)),
        const SizedBox(width: 10),
        Expanded(child: _pillButton('Data Anak', 1)),
      ],
    );
  }

  Widget _pillButton(String label, int index) {
    final selected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.teal),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.teal,
            fontWeight: FontWeight.w600,
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
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      alamat: _alamatController.text.trim().isEmpty ? null : _alamatController.text.trim(),
    );

    try {
      await _penggunaService.update(_uid!, updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data personal disimpan.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      children: [
        const Text('Nama', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        _FieldBox(controller: _namaController),
        const SizedBox(height: 16),
        const Text('No.Telp', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        _FieldBox(controller: _noHpController, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        const Text('E-Mail (opsional)', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        _FieldBox(controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        const Text('Alamat', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        _FieldBox(controller: _alamatController),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
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
      nik: _nikController.text.trim().isEmpty ? null : _nikController.text.trim(),
    );

    final success = await controller.updateData(anak.id!, updated);
    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data anak disimpan.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnakController());
    final uid = AuthService().currentUser?.uid;

    return Obx(() {
      final anakSaya = controller.anakList.where((a) => a.idUser == uid).toList();

      if (anakSaya.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum ada data anak.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(20)),
                child: Text('Profil Anak ${_selectedIndex + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedIndex,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
                    items: List.generate(
                      anakSaya.length,
                      (i) => DropdownMenuItem(
                        value: i,
                        child: Text(
                          anakSaya[i].namaAnak.length > 14
                              ? '${anakSaya[i].namaAnak.substring(0, 14)}...'
                              : anakSaya[i].namaAnak,
                        ),
                      ),
                    ),
                    onChanged: (value) => setState(() => _selectedIndex = value ?? 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Nama Anak', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _FieldBox(controller: _namaAnakController),
          const SizedBox(height: 16),
          const Text('Tanggal Lahir', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Text(
                _tanggalLahir == null
                    ? 'Pilih tanggal'
                    : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _jenisKelamin,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: 'laki-laki',
                    child: Row(children: const [
                      Icon(Icons.male, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Laki-laki'),
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'perempuan',
                    child: Row(children: const [
                      Icon(Icons.female, color: Colors.pink, size: 20),
                      SizedBox(width: 8),
                      Text('Perempuan'),
                    ]),
                  ),
                ],
                onChanged: (value) => setState(() => _jenisKelamin = value ?? 'laki-laki'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('NIK', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _FieldBox(controller: _nikController, keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TambahAnakUserPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Data Anak'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _isSaving ? null : () => _submit(controller, anak),
              child: _isSaving
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
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
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
