import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/auth_service.dart';
import '../../../utils/date_formatter.dart';
import '../widgets/user_header.dart';
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
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(
        context,
        hideNotification: true,
        hideProfileIcon: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const TambahAnakUserPage())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah profil anak',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00A884),
      ),
      body: Obx(() {
        final anakSaya = controller.anakList
            .where((a) => a.idUser == uid)
            .toList();

        return Column(
          children: [
            _buildPageHeader(context),
            Expanded(
              child: controller.anakList.isEmpty && controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : anakSaya.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 28, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F7F2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  children: const [
                                    Icon(Icons.family_restroom,
                                        size: 72, color: Color(0xFF00A884)),
                                    SizedBox(height: 18),
                                    Text(
                                      'Belum ada data anak',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF17394D),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Tambahkan profil anak Anda untuk melihat jadwal imunisasi dan informasi kesehatan penting.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF4B636E),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF7F1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A884),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.child_care,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Anak Saya',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF17394D),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${anakSaya.length} anak terdaftar',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF607383),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            ...anakSaya.map(
                              (anak) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _AnakCard(
                                  anak: anak,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AnakSayaJadwalPage(anak: anak),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                  'Riwayat Imunisasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lihat daftar anak dan riwayat imunisasi.',
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

class _AnakCard extends StatelessWidget {
  final Anak anak;
  final VoidCallback onTap;

  const _AnakCard({required this.anak, required this.onTap});

  String _ageLabel(DateTime dob) {
    final now = DateTime.now();
    var years = now.year - dob.year;
    var months = now.month - dob.month;
    if (now.day < dob.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years > 0) {
      return '$years tahun${months > 0 ? ' $months bln' : ''}';
    }
    return '$months bulan';
  }

  @override
  Widget build(BuildContext context) {
    final isBoy = anak.jenisKelamin == 'laki-laki';
    final avatarColor = isBoy ? const Color(0xFFB5E2F5) : const Color(0xFFF6D1E9);
    final iconColor = isBoy ? const Color(0xFF2579A9) : const Color(0xFFD13B8A);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE6F2EF)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor,
                child: Icon(
                  isBoy ? Icons.boy : Icons.girl,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anak.namaAnak,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF17394D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lahir: ${formatTanggal(anak.tanggalLahir)}',
                      style: const TextStyle(color: Color(0xFF607383)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _ageLabel(anak.tanggalLahir),
                      style: const TextStyle(color: Color(0xFF4B636E)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF607383)),
            ],
          ),
        ),
      ),
    );
  }
}
