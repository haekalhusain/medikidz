import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import 'anak_form_page.dart';
import 'anak_jadwal_page.dart';

class AnakListPage extends StatelessWidget {
  const AnakListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnakController());

    return Scaffold(
      appBar: AppBar(title: const Text('Data Anak')),
      body: Obx(() {
        if (controller.anakList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.anakList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada data anak. Anak baru ditambahkan lewat menu "Tambah Anak (akun ada)" '
                'atau otomatis saat orang tua registrasi.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.anakList.length,
          itemBuilder: (context, index) {
            final anak = controller.anakList[index];
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
