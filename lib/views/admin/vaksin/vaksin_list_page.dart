import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';
import 'vaksin_form_page.dart';
import '../profile/profile_page.dart';

class VaksinListPage extends StatelessWidget {
  const VaksinListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaksinController());

    // Color Palette
    const primaryTeal = Color(0xFF52C49C);
    const lightTealBg = Color(0xFFE8F7F2);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Data Vaksin',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Icon Notifikasi
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
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
                    onPressed: () {
                      // Action notifikasi
                    },
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
                        '1',
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
          // Icon Profile (Navigasi ke ProfilePage)
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
                  size: 22,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.vaksinList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Tombol "+ Stok Vaksinasi" di bagian Atas
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VaksinFormPage()),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'Stok Vaksinasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kondisi Jika Data Kosong
            if (controller.vaksinList.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'Belum ada data vaksin.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              // Listing Kartu Vaksin
              ...controller.vaksinList.map((vaksin) {
                return _VaksinCard(
                  vaksin: vaksin,
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VaksinFormPage(vaksin: vaksin),
                    ),
                  ),
                  onDelete: () =>
                      _confirmDelete(context, controller, vaksin.id!),
                );
              }),

            // Padding bawah tambahan agar tidak tertutup Bottom Navigation Bar Shell
            const SizedBox(height: 80),
          ],
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, VaksinController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Vaksin'),
        content: const Text('Yakin ingin menghapus data vaksin ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.delete(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _VaksinCard extends StatelessWidget {
  final Vaksin vaksin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VaksinCard({
    required this.vaksin,
    required this.onEdit,
    required this.onDelete,
  });

  // Warna border & background berdasarkan status stok
  Color get _accentColor {
    switch (vaksin.statusStok) {
      case 'tersedia':
        return const Color(0xFF52C49C); // Hijau Teal
      case 'menipis':
        return const Color(0xFFF1B44C); // Oranye / Kuning Gold
      default:
        return const Color.fromARGB(255, 222, 69, 69); // Oranye
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringkasan =
        vaksin.informasi.isNotEmpty ? vaksin.informasi.first.subjudul : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        border: Border.all(color: _accentColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kartu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.vaccines, color: Colors.black87, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vaksin.namaVaksin,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Tombol "Lihat Detail >"
                InkWell(
                  onTap: () {
                    // Handler detail jika diperlukan
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81D8D0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Garis Pemisah Hitam Tegas di Tengah
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black26, // Dibuat menjadi garis warna hitam halus
          ),

          // Isi Konten Kartu
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Teks Informasi di Sebelah Kiri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ringkasan.isNotEmpty) ...[
                        Text(
                          ringkasan,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        'Stok : ${vaksin.jumlahStok}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status : ${vaksin.statusLabel}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Edit & Delete di Pojok Kanan Bawah tanpa Numpuk
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onEdit,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
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
    );
  }
}
