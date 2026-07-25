import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/pengguna_model.dart';
import 'tambah_anak_form_page.dart';

class CariAkunPage extends StatefulWidget {
  const CariAkunPage({super.key});

  @override
  State<CariAkunPage> createState() => _CariAkunPageState();
}

class _CariAkunPageState extends State<CariAkunPage> {
  final _searchController = TextEditingController();
  List<Pengguna> _hasil = [];
  bool _isLoading = false;
  bool _sudahCari = false;

  Future<void> _cariAkun() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
      _sudahCari = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tb_pengguna')
          .where('no_hp', isEqualTo: keyword)
          .get();

      setState(() {
        _hasil = snapshot.docs.map((doc) => Pengguna.fromJson(doc.data(), doc.id)).toList();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anak — Cari Akun Orang Tua')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cari akun orang tua berdasarkan nomor WhatsApp yang terdaftar. '
              'Akun harus sudah registrasi (lewat OTP) sebelum anak baru bisa ditambahkan.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Nomor HP, contoh: 6281234567890',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _cariAkun(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _cariAkun, child: const Text('Cari')),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (!_isLoading && _sudahCari && _hasil.isEmpty)
              const Text('Akun tidak ditemukan. Pastikan orang tua sudah registrasi di app.'),
            if (!_isLoading && _hasil.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _hasil.length,
                  itemBuilder: (context, index) {
                    final akun = _hasil[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(akun.nama),
                        subtitle: Text(akun.noHp),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TambahAnakFormPage(
                                  idUser: akun.id!,
                                  namaOrangTua: akun.nama,
                                ),
                              ),
                            );
                          },
                          child: const Text('Tambah Anak'),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
