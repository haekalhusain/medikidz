import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';
import 'vaksin_form_page.dart';

class VaksinListPage extends StatelessWidget {
  const VaksinListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaksinController());

    return Scaffold(
      appBar: AppBar(title: const Text('Data Vaksin')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VaksinFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Stok Vaksinasi'),
      ),
      body: Obx(() {
        if (controller.vaksinList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.vaksinList.isEmpty) {
          return const Center(child: Text('Belum ada data vaksin.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.vaksinList.length,
          itemBuilder: (context, index) {
            final vaksin = controller.vaksinList[index];
            return _VaksinCard(
              vaksin: vaksin,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => VaksinFormPage(vaksin: vaksin)),
              ),
              onDelete: () => _confirmDelete(context, controller, vaksin.id!),
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

class _VaksinCard extends StatelessWidget {
  final Vaksin vaksin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VaksinCard({required this.vaksin, required this.onEdit, required this.onDelete});

  Color get _accentColor {
    switch (vaksin.statusStok) {
      case 'tersedia':
        return Colors.teal;
      case 'menipis':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringkasan = vaksin.informasi.isNotEmpty ? vaksin.informasi.first.subjudul : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.06),
        border: Border.all(color: _accentColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vaccines, color: _accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(vaksin.namaVaksin,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Lihat Detail',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (ringkasan.isNotEmpty) Text(ringkasan, style: const TextStyle(fontSize: 13)),
            Text('Stok : ${vaksin.jumlahStok}', style: const TextStyle(fontSize: 13)),
            Text('Status : ${vaksin.statusLabel}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
