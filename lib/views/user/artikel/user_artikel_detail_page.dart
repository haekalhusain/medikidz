import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/user_header.dart'; // File header reusable Anda
import '../../../models/artikel_model.dart';
import '../../../utils/date_formatter.dart';

class UserArtikelDetailPage extends StatelessWidget {
  final Artikel artikel;

  const UserArtikelDetailPage({super.key, required this.artikel});

  String _formatTanggal(DateTime dt) {
    return formatTanggal(dt);
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF52C49C);
    const lightTealBg = Color(0xFFE8F7F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(context), // Menggunakan header dari user_header.dart
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Banner Artikel dengan Tombol Back Transparan & Rounded Box
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  color: lightTealBg,
                  child: artikel.gambarUrl != null && artikel.gambarUrl!.isNotEmpty
                      ? Image.network(
                          artikel.gambarUrl!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image, size: 50, color: primaryTeal),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.article, size: 60, color: primaryTeal),
                        ),
                ),

                // Tombol Back Agak Transparan, Agak Kotak Rounded (Mencegah BottomNavBar Hilang)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85), // Agak transparan
                      borderRadius: BorderRadius.circular(12), // Kotak dengan sudut rounded
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Menggunakan Get.back() agar stack BottomNavigationBar tidak hancur/hilang
                          if (Navigator.canPop(context)) {
                            Get.back();
                          } else {
                            Get.back();
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Header Artikel (Badge Kategori, Judul, Tanggal)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Kategori (Chip Style)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: lightTealBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryTeal.withOpacity(0.5)),
                    ),
                    child: Text(
                      artikel.kategori,
                      style: const TextStyle(
                        color: primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Judul Artikel
                  Text(
                    artikel.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tanggal Upload
                  Text(
                    _formatTanggal(artikel.tanggalUpload),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Section Author / Penulis Artikel
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_medikidz.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: primaryTeal,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Author',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tim Medis Klinik Medikidz',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

            // 4. Detail Konten Artikel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ringkasan Sebagai Paragraf Pembuka
                  if (artikel.ringkasan.isNotEmpty) ...[
                    Text(
                      artikel.ringkasan,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Konten Dinamis (Subjudul & Isi)
                  if (artikel.konten.isEmpty) ...[
                    if (artikel.ringkasan.isEmpty)
                      const Text(
                        'Belum ada isi detail untuk artikel ini.',
                        style: TextStyle(color: Colors.black54),
                      ),
                  ] else ...[
                    ...artikel.konten.map((section) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (section.subjudul.isNotEmpty) ...[
                              Text(
                                section.subjudul,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            Text(
                              section.isi,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}