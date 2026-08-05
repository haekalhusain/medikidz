import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../services/auth_service.dart';
import '../../../utils/date_formatter.dart';
import 'anak_saya_jadwal_page.dart';
import 'tambah_anak_user_page.dart';

/// Daftar anak milik user yang sedang login. Mendukung multi-anak --
/// 1 akun user boleh punya lebih dari 1 anak, ditambahkan sendiri lewat
/// halaman ini, atau oleh admin lewat menu Data Anak.
class AnakSayaListPage extends StatelessWidget {
  const AnakSayaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnakController());
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Anak Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TambahAnakUserPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Anak'),
      ),
      body: Obx(() {
        if (controller.anakList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final anakSaya = controller.anakList.where((a) => a.idUser == uid).toList();

        if (anakSaya.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada data anak. Tambahkan lewat tombol "Tambah Anak" di bawah.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: anakSaya.length,
          itemBuilder: (context, index) {
            final anak = anakSaya[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AnakSayaJadwalPage(anak: anak)),
                ),
                leading: CircleAvatar(
                  child: Icon(anak.jenisKelamin == 'laki-laki' ? Icons.boy : Icons.girl),
                ),
                title: Text(anak.namaAnak),
                subtitle: Text('Lahir: ${_formatDate(anak.tanggalLahir)}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      }),
    );
  }

  String _formatDate(DateTime date) => formatTanggal(date);
}
