/// Menampilkan jadwal imunisasi yang DIHITUNG OTOMATIS untuk semua anak,
/// berdasarkan tanggal lahir tiap anak (tb_anak) + template (tb_jadwalMaster).
/// Tidak perlu input manual satu-satu -- begitu ada anak baru atau
/// Jadwal Master diperbarui, daftar ini otomatis ikut menyesuaikan.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/jadwal_controller.dart';
import '../../../controllers/jadwal_master_controller.dart';
import '../../../controllers/anak_controller.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/anak_model.dart';
import '../../../services/jadwal_schedule_service.dart';
import '../../../services/jadwal_status_updater.dart';
import '../../../utils/date_formatter.dart';
import '../widgets/admin_header.dart';

class KelolaJadwalListPage extends StatefulWidget {
  const KelolaJadwalListPage({super.key});

  @override
  State<KelolaJadwalListPage> createState() => _KelolaJadwalListPageState();
}

enum _FilterStatus { semua, terlambat, akanDatang }

class _KelolaJadwalListPageState extends State<KelolaJadwalListPage> {
  bool _hanyaHariIni = true;
  _FilterStatus _filterStatus = _FilterStatus.semua;
  final _searchController = TextEditingController();
  String _query = '';
  final JadwalScheduleService _scheduleService = JadwalScheduleService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anakController = Get.put(AnakController());
    final masterController = Get.put(JadwalMasterController());
    final jadwalController = Get.put(JadwalController());
    final vaksinController = Get.put(VaksinController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAdminTopBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // --- TITLE & ACTION BACK ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal Imunisasi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        'Kelola semua Jadwal Imunisasi pada aplikasi',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari jadwal imunisasi..',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF359D89), width: 1.5),
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),

            // --- FILTER CHIPS ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCustomChip(
                      label: 'Hari Ini',
                      isSelected: _hanyaHariIni,
                      onTap: () => setState(() => _hanyaHariIni = true),
                    ),
                    const SizedBox(width: 8),
                    _buildCustomChip(
                      label: 'Semua Jadwal',
                      isSelected: !_hanyaHariIni,
                      onTap: () => setState(() => _hanyaHariIni = false),
                    ),
                    const SizedBox(width: 12),
                    Container(height: 16, width: 1, color: Colors.grey.shade300),
                    const SizedBox(width: 12),
                    _buildCustomChip(
                      label: 'Terlambat',
                      isSelected: _filterStatus == _FilterStatus.terlambat,
                      activeColor: Colors.red.shade400,
                      onTap: () => setState(() => _filterStatus =
                          _filterStatus == _FilterStatus.terlambat ? _FilterStatus.semua : _FilterStatus.terlambat),
                    ),
                    const SizedBox(width: 8),
                    _buildCustomChip(
                      label: 'Akan Datang',
                      isSelected: _filterStatus == _FilterStatus.akanDatang,
                      activeColor: Colors.amber.shade700,
                      onTap: () => setState(() => _filterStatus =
                          _filterStatus == _FilterStatus.akanDatang ? _FilterStatus.semua : _FilterStatus.akanDatang),
                    ),
                  ],
                ),
              ),
            ),

            // --- DAFTAR LIST JADWAL ---
            Expanded(
              child: Obx(() {
                final masterList = masterController.jadwalMasterList;
                if (masterList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Jadwal master belum diisi. Isi dulu lewat menu "Jadwal Master".',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final now = DateTime.now();
                final semuaBaris = <_BarisJadwal>[];
                for (final anak in anakController.anakList) {
                  final jadwal = _scheduleService.computeJadwalForAnak(
                    anak: anak,
                    masterList: masterList,
                    semuaJadwalImunisasi: jadwalController.jadwalList,
                  );
                  for (final j in jadwal) {
                    if (j.sudah) continue;
                    semuaBaris.add(_BarisJadwal(anak: anak, item: j));
                  }
                }

                semuaBaris.sort((a, b) => a.item.tanggalJadwal.compareTo(b.item.tanggalJadwal));

                var tampil = _hanyaHariIni
                    ? semuaBaris.where((b) {
                        final t = b.item.tanggalJadwal;
                        return t.year == now.year && t.month == now.month && t.day == now.day;
                      }).toList()
                    : semuaBaris;

                if (_filterStatus == _FilterStatus.terlambat) {
                  tampil = tampil.where((b) => b.item.statusLabel == 'Terlambat').toList();
                } else if (_filterStatus == _FilterStatus.akanDatang) {
                  tampil = tampil.where((b) => b.item.statusLabel == 'Akan Datang').toList();
                }

                if (_query.isNotEmpty) {
                  tampil = tampil
                      .where((b) =>
                          b.anak.namaAnak.toLowerCase().contains(_query) ||
                          b.item.master.namaVaksin.toLowerCase().contains(_query))
                      .toList();
                }

                if (tampil.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada jadwal yang cocok dengan filter.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: tampil.length,
                  itemBuilder: (context, index) {
                    final baris = tampil[index];
                    final isTerlambat = baris.item.statusLabel == 'Terlambat';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // AVATAR PROFIL DENGAN BADGE NOTIFIKASI DI UJUNG
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              // Badge Notifikasi di Ujung Bulatan Profile
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isTerlambat ? Colors.redAccent : const Color(0xFFFF9800),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(
                                    isTerlambat ? Icons.priority_high_rounded : Icons.access_time_filled_rounded,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // INFORMASI ANAK & VAKSIN
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        baris.anak.namaAnak,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // BADGE STATUS DI POJOK KANAN CARD
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isTerlambat
                                            ? const Color(0xFFFFEAEA)
                                            : const Color(0xFFFFF4E5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        baris.item.statusLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isTerlambat
                                              ? Colors.redAccent
                                              : const Color(0xFFE65100),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Vaksin Info
                                Row(
                                  children: [
                                    const Icon(Icons.vaccines_outlined, size: 16, color: Color(0xFF359D89)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${baris.item.master.namaVaksin} — Dosis ${baris.item.master.urutanDosis}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Tanggal Info
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF359D89)),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(baris.item.tanggalJadwal),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // TOMBOL SELESAI / KONFIRMASI DI KANAN BAWAH
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => _konfirmasi(context, jadwalController, vaksinController, baris),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F4F1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF359D89)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Selesai',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF359D89),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER CHIP FILTER
  Widget _buildCustomChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? const Color(0xFF359D89);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Future<void> _konfirmasi(
    BuildContext context,
    JadwalController jadwalController,
    VaksinController vaksinController,
    _BarisJadwal baris,
  ) async {
    final vaksinDariKlinik = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Imunisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(
          'Tandai "${baris.item.master.namaVaksin}" untuk ${baris.anak.namaAnak} sebagai SUDAH diimunisasi?\n\n'
          'Apakah vaksinnya dari stok klinik ini? Kalau "Ya", stok otomatis dikurangi 1.',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF359D89)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Bukan Klinik', style: TextStyle(color: Color(0xFF359D89))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF359D89),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Dari Klinik', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (vaksinDariKlinik == null || !context.mounted) return;

    await JadwalStatusUpdater.ubahStatus(
      jadwalController: jadwalController,
      vaksinController: vaksinController,
      anak: baris.anak,
      item: baris.item,
      status: 'sudah imunisasi',
      vaksinDariKlinik: vaksinDariKlinik,
    );
  }

  String _formatDate(DateTime date) => formatTanggal(date);
}

class _BarisJadwal {
  final Anak anak;
  final JadwalTerjadwal item;
  _BarisJadwal({required this.anak, required this.item});
}