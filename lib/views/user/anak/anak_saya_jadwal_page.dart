import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/jadwal_schedule_service.dart';
import '../../../utils/date_formatter.dart';
import '../widgets/user_header.dart';
import '../../admin/anak/jadwal_matrix_widget.dart';

/// Versi READ-ONLY dari jadwal imunisasi anak (khusus orang tua/user).
/// Tidak ada tombol ubah status -- itu wewenang admin/perawat di klinik.
class AnakSayaJadwalPage extends StatelessWidget {
  final Anak anak;
  AnakSayaJadwalPage({super.key, required this.anak});

  final JadwalMasterController _masterController = Get.put(
    JadwalMasterController(),
  );
  final JadwalController _jadwalController = Get.put(JadwalController());
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildUserTopBar(
        context,
        hideNotification: true,
        hideProfileIcon: true,
      ),
      body: Obx(() {
        final masterList = _masterController.jadwalMasterList;
        if (masterList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Jadwal imunisasi belum tersedia. Hubungi klinik.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final jadwal = _scheduleService.computeJadwalForAnak(
          anak: anak,
          masterList: masterList,
          semuaJadwalImunisasi: _jadwalController.jadwalList,
        );

        final riwayat = jadwal.where((j) => j.sudah).toList()
          ..sort(
            (a, b) => b.realisasi!.tanggalImunisasi.compareTo(
              a.realisasi!.tanggalImunisasi,
            ),
          );

        final selesaiCount = jadwal.where((j) => j.sudah).length;
        final terlambatCount = jadwal.where((j) => !j.sudah && j.statusLabel == 'Terlambat').length;
        final sedangDiprosesCount = jadwal.where((j) => !j.sudah && j.statusLabel != 'Terlambat').length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            _buildPageHeader(context),
            const SizedBox(height: 18),
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildSummaryCards(selesaiCount, sedangDiprosesCount, terlambatCount),
            const SizedBox(height: 20),
            _buildSectionTitle('Rencana Imunisasi 2 Tahun ke Depan'),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: JadwalMatrixWidget(jadwal: jadwal),
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Rincian Lengkap'),
            const SizedBox(height: 10),
            ...jadwal.map((j) => _buildJadwalCard(j)),
            const SizedBox(height: 22),
            _buildSectionTitle('Riwayat Imunisasi'),
            const SizedBox(height: 10),
            if (riwayat.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Belum ada imunisasi yang tercatat.',
                  style: TextStyle(color: Color(0xFF607383)),
                ),
              )
            else
              ...riwayat.map((j) => _buildRiwayatCard(j)),
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
                  'Detail jadwal imunisasi dan riwayat anak Anda.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F2),
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
              Icons.schedule,
              color: Colors.white,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17394D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Jadwal imunisasi anakmu lengkap dan mudah dipantau di satu tempat.',
                  style: const TextStyle(
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
    );
  }

  Widget _buildSummaryCards(int selesai, int sedangDiproses, int terlambat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard('Selesai', selesai, const Color(0xFF00A884)),
        _buildSummaryCard('Sedang Diproses', sedangDiproses, const Color(0xFF56C3A2)),
        _buildSummaryCard('Terlambat', terlambat, const Color(0xFFE5593D)),
      ],
    );
  }

  Widget _buildSummaryCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF17394D),
      ),
    );
  }

  Widget _buildJadwalCard(dynamic j) {
    final color = j.sudah
        ? const Color(0xFF1B8F5F)
        : (j.statusLabel == 'Terlambat' ? const Color(0xFFE5593D) : const Color(0xFFF1A33C));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.16),
          child: Icon(
            j.sudah ? Icons.check_circle : Icons.schedule,
            color: color,
          ),
        ),
        title: Text(
          '${j.master.namaVaksin} - Dosis ${j.master.urutanDosis}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF17394D),
          ),
        ),
        subtitle: Text(
          'Usia: ${j.master.usiaLabel} • Jadwal: ${_formatDate(j.tanggalJadwal)}',
          style: const TextStyle(color: Color(0xFF607383)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            j.statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(dynamic j) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EFF3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F7EE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Color(0xFF1B8F5F), size: 20),
        ),
        title: Text(
          '${j.master.namaVaksin} - Dosis ${j.master.urutanDosis}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF17394D),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDate(j.realisasi!.tanggalImunisasi),
              style: const TextStyle(color: Color(0xFF607383)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => formatTanggal(date);
}
