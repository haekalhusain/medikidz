import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/artikel_controller.dart';
import 'artikel_form_page.dart';

class ArtikelListPage extends StatelessWidget {
  const ArtikelListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtikelController());

    return Scaffold(
      appBar: AppBar(title: const Text('Artikel Edukasi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ArtikelFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Artikel'),
      ),
      body: Obx(() {
        if (controller.artikelList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.artikelList.isEmpty) {
          return const Center(child: Text('Belum ada artikel. Tambahkan artikel pertama.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.artikelList.length,
          itemBuilder: (context, index) {
            final artikel = controller.artikelList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ArtikelFormPage(artikel: artikel)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (artikel.gambarUrl != null)
                      Image.network(artikel.gambarUrl!, height: 140, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(artikel.kategori,
                                style: const TextStyle(fontSize: 11, color: Colors.teal)),
                          ),
                          const SizedBox(height: 6),
                          Text(artikel.judul,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(artikel.ringkasan,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ArtikelFormPage(artikel: artikel)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _confirmDelete(context, controller, artikel.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  void _confirmDelete(BuildContext context, ArtikelController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Yakin ingin menghapus artikel ini?'),
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
