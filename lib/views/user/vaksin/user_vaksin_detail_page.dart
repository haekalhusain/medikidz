import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/user_header.dart';
import '../../../models/vaksin_model.dart';

class UserVaksinDetailPage extends StatelessWidget {
  final Vaksin vaksin;

  const UserVaksinDetailPage({super.key, required this.vaksin});

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah vaksin termasuk program pemerintah atau bukan
    final isPemerintah = vaksin.kategoriVaksin
        .toLowerCase()
        .contains('pemerintahan');

    // Pengaturan Warna Kotak Kategori sesuai Gambar
    final categoryBgColor = isPemerintah
        ? const Color(0xFFB5FAD4) // Hijau mint (Pemerintahan)
        : const Color(0xFFFFE6CC); // Orange muda (Non-Pemerintah)

    final categoryBorderColor = isPemerintah
        ? const Color(0xFF52C49C)
        : const Color(0xFFE5A86A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Navigasi Tombol Back
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Detail Vaksin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Section 1: Nama & Deskripsi Vaksin (styled)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2E9DC),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.vaccines,
                      size: 24,
                      color: Color(0xFF0F6F5A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widgetNamaVaksin(vaksin.namaVaksin),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (vaksin.informasi.isNotEmpty &&
                            vaksin.informasi.first.subjudul.isNotEmpty)
                          Text(
                            vaksin.informasi.first.subjudul,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Garis Pembatas Strip Mint
            Container(
              height: 8,
              width: double.infinity,
              color: const Color(0xFFC2E9DC),
            ),

            // Section 2: Kategori Vaksin
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori Vaksin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: categoryBgColor,
                      border: Border.all(color: categoryBorderColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      vaksin.kategoriVaksin.isNotEmpty
                          ? vaksin.kategoriVaksin
                          : (isPemerintah
                              ? 'Program Pemerintahan (Imunisasi Rutin Wajib)'
                              : 'Non-Pemerintah (Imunisasi Pilihan / Tambahan)'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Section 3: Detail Stok Klinik (card)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sisa Stok Fisik',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${vaksin.jumlahStok} Vial',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 48, color: const Color(0xFFF1F1F1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Stok',
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getStatusDotColor(vaksin.statusStok),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vaksin.statusLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
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

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Section 4: Informasi Medis (Berdasarkan IDAI)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Medis (Berdasarkan IDAI)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (vaksin.informasi.isEmpty)
                    const Text(
                      'Belum ada informasi medis tambahan.',
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    )
                  else
                    ...vaksin.informasi.map(
                      (info) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FFF9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE8F6EF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (info.subjudul.isNotEmpty)
                              Text(
                                info.subjudul,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            if (info.subjudul.isNotEmpty) const SizedBox(height: 6),
                            if (info.isi.isNotEmpty)
                              Text(
                                info.isi,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String widgetNamaVaksin(String rawName) {
    if (rawName.toLowerCase().startsWith('vaksin')) {
      return rawName;
    }
    return 'Vaksin $rawName';
  }

  Color _getStatusDotColor(String statusKey) {
    switch (statusKey) {
      case 'tersedia':
        return const Color(0xFF52C49C);
      case 'menipis':
        return const Color(0xFFF1B44C);
      default:
        return const Color(0xFFE57373);
    }
  }
}