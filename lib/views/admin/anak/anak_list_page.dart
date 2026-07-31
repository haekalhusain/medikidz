import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import 'anak_form_page.dart';
import 'anak_jadwal_page.dart';
import 'tambah_anak_form_page.dart';

class AnakListPage extends StatefulWidget {
  const AnakListPage({super.key});

  @override
  State<AnakListPage> createState() => _AnakListPageState();
}

class _AnakListPageState extends State<AnakListPage> {
  final _searchController = TextEditingController();
  final _query = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnakController());

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Imunisasi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TambahAnakFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Anak'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _query.value = value.trim().toLowerCase(),
              decoration: InputDecoration(
                hintText: 'Cari nama anak..',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                suffixIcon: Obx(() => _query.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _query.value = '';
                        },
                      )),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.anakList.isEmpty && controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.anakList.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada data anak. Anak baru ditambahkan lewat menu "Tambah Anak" '
                      'atau otomatis saat orang tua registrasi.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final hasil = _query.value.isEmpty
                  ? controller.anakList
                  : controller.anakList
                      .where((a) => a.namaAnak.toLowerCase().contains(_query.value))
                      .toList();

              if (hasil.isEmpty) {
                return const Center(child: Text('Nama anak tidak ditemukan.'));
              }

              return ListView.builder(
                itemCount: hasil.length,
                itemBuilder: (context, index) {
                  final anak = hasil[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AnakJadwalPage(anak: anak)),
                      ),
                      leading: CircleAvatar(
                        child: Icon(anak.jenisKelamin == 'laki-laki' ? Icons.boy : Icons.girl),
                      ),
                      title: Text(anak.namaAnak),
                      subtitle: Text('Lahir: ${_formatDate(anak.tanggalLahir)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => AnakFormPage(anak: anak)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => _confirmDelete(context, controller, anak.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _confirmDelete(BuildContext context, AnakController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data Anak'),
        content: const Text(
            'Data akan disembunyikan dari daftar, tapi tetap tersimpan untuk keperluan riwayat medis. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.delete(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
