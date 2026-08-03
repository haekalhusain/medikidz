import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/anak_controller.dart';
import 'anak_form_page.dart';
import 'anak_jadwal_page.dart';
import 'tambah_anak_form_page.dart';
import '../widgets/admin_header.dart';

class AnakListPage extends StatefulWidget {
  const AnakListPage({super.key});

  @override
  State<AnakListPage> createState() => _AnakListPageState();
}

class _AnakListPageState extends State<AnakListPage> {
  final _searchController = TextEditingController();
  final _query = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnakController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAdminTopBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TambahAnakFormPage()),
        ),
        backgroundColor: const Color(0xFF359D89),
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
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
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Imunisasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Daftar anak dan riwayat imunisasi',
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
                onChanged: (value) => _query.value = value.trim().toLowerCase(),
                decoration: InputDecoration(
                  hintText: 'Cari nama anak..',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: Color(0xFF359D89),
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: Obx(
                    () => _query.value.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _query.value = '';
                            },
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // --- DAFTAR LIST ANAK ---
            Expanded(
              child: Obx(() {
                if (controller.anakList.isEmpty && controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF359D89)),
                  );
                }
                if (controller.anakList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Belum ada data anak. Anak baru ditambahkan lewat menu "Tambah Anak" '
                        'atau otomatis saat orang tua registrasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  );
                }

                final hasil = _query.value.isEmpty
                    ? controller.anakList
                    : controller.anakList
                        .where(
                          (a) => a.namaAnak.toLowerCase().contains(_query.value),
                        )
                        .toList();

                if (hasil.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nama anak tidak ditemukan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: hasil.length,
                  itemBuilder: (context, index) {
                    final anak = hasil[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AnakJadwalPage(anak: anak),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF359D89),
                                        Color(0xFF4FC3A1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    anak.jenisKelamin == 'laki-laki'
                                        ? Icons.boy_rounded
                                        : Icons.girl_rounded,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              anak.namaAnak,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F7F2),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              'Lihat detail',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF359D89),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.cake_outlined,
                                            size: 15,
                                            color: Color(0xFF359D89),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Lahir: ${_formatDate(anak.tanggalLahir)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF64748B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            anak.jenisKelamin == 'laki-laki'
                                                ? Icons.male_rounded
                                                : Icons.female_rounded,
                                            size: 15,
                                            color: const Color(0xFF359D89),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            anak.jenisKelamin == 'laki-laki'
                                                ? 'Laki-laki'
                                                : 'Perempuan',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Ketuk kartu untuk melihat riwayat dan jadwal imunisasi',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildActionButton(
                                            icon: Icons.edit_outlined,
                                            color: const Color(0xFF64748B),
                                            onTap: () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => AnakFormPage(
                                                  anak: anak,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildActionButton(
                                            icon: Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                            onTap: () => _confirmDelete(
                                              context,
                                              controller,
                                              anak.id!,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _confirmDelete(
    BuildContext context,
    AnakController controller,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Data Anak',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Data akan disembunyikan dari daftar, tapi tetap tersimpan untuk keperluan riwayat medis. Lanjutkan?',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.delete(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
