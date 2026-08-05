import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medikidz/views/user/profile/profil_anda_page.dart';
import '../../../models/artikel_model.dart';
import '../../../utils/date_formatter.dart';
// Import file profil anda (sesuaikan path foldernya jika perlu)


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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
        actions: [
          // Icon Notifikasi dengan Badge
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                color: lightTealBg,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: primaryTeal,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Icon Profile (Direct ke ProfilAndaPage)
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: const BoxDecoration(
                color: lightTealBg,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person,
                  color: primaryTeal,
                  size: 24,
                ),
                onPressed: () {
                  Get.to(() => const ProfilAndaPage());
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Banner Artikel
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

            // 2. Header Artikel (Badge Kategori, Judul, Tanggal)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Kategori (Chip Style)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: lightTealBg,
                      borderRadius: BorderRadius.circular(8),
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
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

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

            // Garis Divider Pemisah
            Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

            // 3. Ringkasan (KOTAK/SUMMARY BOX SEPERTI SEMULA) & Detail Konten
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kotak Ringkasan (Style Awal)
                  if (artikel.ringkasan.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: lightTealBg,
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          left: BorderSide(color: primaryTeal, width: 4),
                        ),
                      ),
                      child: Text(
                        artikel.ringkasan,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
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