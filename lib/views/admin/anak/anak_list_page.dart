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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
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
                              // AVATAR PROFIL ANAK
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  anak.jenisKelamin == 'laki-laki'
                                      ? Icons.boy_rounded
                                      : Icons.girl_rounded,
                                  size: 38,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // DETAIL DATA ANAK
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      anak.namaAnak,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    // Tanggal Lahir
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.cake_outlined,
                                          size: 15,
                                          color: Color(0xFF359D89),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Lahir: ${_formatDate(anak.tanggalLahir)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // Jenis Kelamin
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

                                    const SizedBox(height: 10),

                                    // TOMBOL AKSI (EDIT & DELETE) DI POJOK KANAN BAWAH CARD
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AnakFormPage(
                                                anak: anak,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          onTap: () => _confirmDelete(
                                            context,
                                            controller,
                                            anak.id!,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.delete_outline_rounded,
                                              size: 20,
                                              color: Colors.redAccent,
                                            ),
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
