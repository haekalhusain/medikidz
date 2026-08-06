import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/artikel_model.dart';
import '../../../utils/date_formatter.dart';
import '../widgets/user_header.dart';

class UserArtikelDetailPage extends StatelessWidget {
  final Artikel artikel;

  const UserArtikelDetailPage({super.key, required this.artikel});

  String _formatTanggal(DateTime dt) {
    return formatTanggal(dt);
  }

  @override
  Widget build(BuildContext context) {
    final notifikasiController = Get.isRegistered<NotifikasiController>()
        ? Get.find<NotifikasiController>()
        : Get.put(NotifikasiController());

    const primaryTeal = Color(0xFF52C49C);
    const lightTealBg = Color(0xFFE8F7F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(
        context,
        showBackButton: true,
        hideNotification: false,
        hideProfileIcon: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Banner Artikel (Diberi padding atas saja, tanpa rounded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
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