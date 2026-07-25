import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import 'vaksin_form_page.dart';

class VaksinListPage extends StatelessWidget {
  const VaksinListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaksinController());

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Vaksin')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VaksinFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.vaksinList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.vaksinList.isEmpty) {
          return const Center(child: Text('Belum ada data vaksin.'));
        }
        return ListView.builder(
          itemCount: controller.vaksinList.length,
          itemBuilder: (context, index) {
            final vaksin = controller.vaksinList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(vaksin.namaVaksin),
                subtitle: Text('Usia: ${vaksin.usiaImunisasi}  •  Stok: ${vaksin.jumlahStok}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusBadge(status: vaksin.statusStok),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => VaksinFormPage(vaksin: vaksin)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _confirmDelete(context, controller, vaksin.id!),
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

  void _confirmDelete(BuildContext context, VaksinController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Vaksin'),
        content: const Text('Yakin ingin menghapus data vaksin ini?'),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'tersedia':
        color = Colors.green;
        break;
      case 'menipis':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
