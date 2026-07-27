import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/riwayat_controller.dart';
import 'riwayat_form_page.dart';

class RiwayatListPage extends StatelessWidget {
  const RiwayatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RiwayatController());

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Riwayat Imunisasi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RiwayatFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Riwayat Luar'),
      ),
      body: Obx(() {
        if (controller.riwayatList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.riwayatList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada riwayat imunisasi luar faskes yang dicatat.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.riwayatList.length,
          itemBuilder: (context, index) {
            final riwayat = controller.riwayatList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.teal),
                title: Text(riwayat.namaVaksin),
                subtitle: Text(
                  '${riwayat.namaAnak}\n'
                  '${_formatDate(riwayat.tanggalImunisasi)}  •  ${riwayat.faskes}'
                  '${riwayat.catatan != null && riwayat.catatan!.isNotEmpty ? '\nCatatan: ${riwayat.catatan}' : ''}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RiwayatFormPage(riwayat: riwayat)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _confirmDelete(context, controller, riwayat.id!),
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

  void _confirmDelete(BuildContext context, RiwayatController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Yakin ingin menghapus riwayat imunisasi ini?'),
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
