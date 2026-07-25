import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_master_controller.dart';
import 'jadwal_master_form_page.dart';

class JadwalMasterListPage extends StatelessWidget {
  const JadwalMasterListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JadwalMasterController());

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Master Imunisasi')),
      body: Obx(() {
        if (controller.jadwalMasterList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.jadwalMasterList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada data. Import seed data (lihat README).', textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.jadwalMasterList.length,
          itemBuilder: (context, index) {
            final item = controller.jadwalMasterList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text('${item.namaVaksin} — dosis ${item.urutanDosis}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usia: ${item.usiaLabel}'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Chip(label: item.kategori),
                        const SizedBox(width: 6),
                        _Chip(label: item.kategoriJendelaPengejaran, color: _colorForKategori(item.kategoriJendelaPengejaran)),
                        const SizedBox(width: 6),
                        if (item.toleransiKeterlambatanHari != null)
                          _Chip(label: 'toleransi ${item.toleransiKeterlambatanHari} hari'),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => JadwalMasterFormPage(item: item)),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _colorForKategori(String kategori) {
    switch (kategori) {
      case 'luas':
        return Colors.green;
      case 'terbatas':
        return Colors.orange;
      case 'tanpa jendela':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;
  const _Chip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: c, fontSize: 10)),
    );
  }
}
