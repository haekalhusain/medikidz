import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_controller.dart';

class JadwalListPage extends StatelessWidget {
  const JadwalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JadwalController());

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Imunisasi')),
      body: Obx(() {
        if (controller.jadwalList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.jadwalList.isEmpty) {
          return const Center(child: Text('Belum ada jadwal imunisasi.'));
        }
        return ListView.builder(
          itemCount: controller.jadwalList.length,
          itemBuilder: (context, index) {
            final jadwal = controller.jadwalList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Icon(
                  jadwal.status == 'sudah imunisasi' ? Icons.check_circle : Icons.pending,
                  color: jadwal.status == 'sudah imunisasi' ? Colors.green : Colors.orange,
                ),
                title: Text(jadwal.namaVaksin ?? '-'),
                subtitle: Text('${jadwal.namaAnak ?? '-'}  •  ${_formatDate(jadwal.tanggalImunisasi)}'),
                trailing: Text(
                  jadwal.status,
                  style: TextStyle(
                    fontSize: 11,
                    color: jadwal.status == 'sudah imunisasi' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
