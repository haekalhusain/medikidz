import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';

/// Info vaksin buat user -- read-only, cuma nampilin nama, kategori,
/// dan info edukasi (subjudul+isi). Tidak ada tombol tambah/edit/hapus,
/// itu wewenang admin.
class UserVaksinListPage extends StatelessWidget {
  const UserVaksinListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaksinController());

    return Scaffold(
      appBar: AppBar(title: const Text('Info Vaksin')),
      body: Obx(() {
        if (controller.vaksinList.isEmpty) {
          return const Center(child: Text('Belum ada data vaksin.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.vaksinList.length,
          itemBuilder: (context, index) {
            final vaksin = controller.vaksinList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(Icons.vaccines, color: Colors.teal),
                title: Text(vaksin.namaVaksin, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(vaksin.kategoriVaksin, style: const TextStyle(fontSize: 12)),
                children: _buildInformasi(vaksin),
              ),
            );
          },
        );
      }),
    );
  }

  List<Widget> _buildInformasi(Vaksin vaksin) {
    if (vaksin.informasi.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text('Belum ada informasi tambahan untuk vaksin ini.', style: TextStyle(color: Colors.black54)),
        ),
      ];
    }

    return vaksin.informasi
        .where((k) => k.subjudul.isNotEmpty || k.isi.isNotEmpty)
        .map((k) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (k.subjudul.isNotEmpty)
                    Text(k.subjudul, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (k.isi.isNotEmpty) Text(k.isi, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ))
        .toList();
  }
}
