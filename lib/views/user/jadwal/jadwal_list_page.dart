import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../utils/date_formatter.dart';
import '../widgets/user_header.dart';

class JadwalListPage extends StatelessWidget {
  const JadwalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JadwalController());

    return Scaffold(
      appBar: buildUserTopBar(
        context,
        hideNotification: true,
        hideProfileIcon: true,
      ),
      body: Obx(() {
        return Column(
          children: [
            _buildPageHeader(context),
            Expanded(
              child: controller.jadwalList.isEmpty
                  ? controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : const Center(child: Text('Belum ada jadwal imunisasi.'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 0),
                      itemCount: controller.jadwalList.length,
                      itemBuilder: (context, index) {
                        final jadwal = controller.jadwalList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Icon(
                              jadwal.status == 'sudah imunisasi'
                                  ? Icons.check_circle
                                  : Icons.pending,
                              color: jadwal.status == 'sudah imunisasi'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            title: Text(jadwal.namaVaksin ?? '-'),
                            subtitle: Text(
                              '${jadwal.namaAnak ?? '-'}  •  ${_formatDate(jadwal.tanggalImunisasi)}',
                            ),
                            trailing: Text(
                              jadwal.status,
                              style: TextStyle(
                                fontSize: 11,
                                color: jadwal.status == 'sudah imunisasi'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Jadwal Imunisasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lihat jadwal imunisasi dan status vaksinasi anak Anda.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => formatTanggal(date);
}
