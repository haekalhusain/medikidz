import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';
import 'vaksin_form_page.dart';
import '../widgets/admin_header.dart';

class VaksinListPage extends StatelessWidget {
  const VaksinListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaksinController());

    // Color Palette
    const primaryTeal = Color(0xFF00A88F);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFB),
      appBar: buildAdminTopBar(context),
      // Floating Action Button (+) Sesuai Desain
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            backgroundColor: primaryTeal,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VaksinFormPage()),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.vaksinList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Judul & Subtitle
            const Text(
              'Vaksin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Kelola semua vaksin disini',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black45,
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

  // LOGIKA WARNA STOK VAKSIN
  Color get _borderColor {
    switch (vaksin.statusStok) {
      case 'tersedia':
        return const Color(0xFF52C49C); // Hijau Teal
      case 'menipis':
        return const Color(0xFFF1B44C); // Kuning / Oranye
      default:
        return const Color(0xFFDE4545); // MERAH jika stok kosong
    }
  }

  Color get _bgColor {
    switch (vaksin.statusStok) {
      case 'tersedia':
        return const Color(0xFFE8F8F3); // Hijau Muda
      case 'menipis':
        return const Color(0xFFFFF6E5); // Oranye/Kuning Muda
      default:
        return const Color(0xFFFFEBEB); // Merah Muda jika stok kosong
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringkasan =
        vaksin.informasi.isNotEmpty ? vaksin.informasi.first.subjudul : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _borderColor, width: 2),
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
                    // Handler detail
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF86E3CE),
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
                            fontWeight: FontWeight.w600,
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

          // Garis Pemisah Tipis
          Divider(
            height: 1,
            thickness: 1,
            color: _borderColor.withOpacity(0.5),
          ),

          // Isi Konten Kartu
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Teks Informasi di Kiri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ringkasan.isNotEmpty) ...[
                        Text(
                          ringkasan,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        'Stok : ${vaksin.jumlahStok}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Status : ${vaksin.statusLabel}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Edit & Delete di Kanan Bawah
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
                          Icons.delete_outline_rounded,
                          size: 22,
                          color: Color(0xFFE55335),
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
