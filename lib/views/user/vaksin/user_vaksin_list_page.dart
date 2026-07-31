import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medikidz/views/user/profile/profil_anda_page.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';
// Import file profil anda (menggunakan huruf "i" pada profil)

/// Info vaksin buat user -- read-only, cuma nampilin nama, kategori,
/// stok, status, dan info edukasi (subjudul+isi). Tidak ada tombol tambah/edit/hapus,
/// itu wewenang admin.
class UserVaksinListPage extends StatelessWidget {
  const UserVaksinListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaksinController());

    // Color Palette
    const primaryTeal = Color(0xFF52C49C);
    const lightTealBg = Color(0xFFE8F7F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Detail Vaksin',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Icon Notifikasi
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

          // Icon Profile (Mengarahkan ke ProfilAndaPage)
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
      body: Column(
        children: [
          // Banner Informasi Penting (Garis Atas & Bawah Abu-abu)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Penting',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Silakan cek ketersediaan stok vaksin sebelum datang ke klinik.\nStatus stok diperbarui otomatis oleh sistem apotek klinik.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Header Banner Toska
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: primaryTeal,
            child: const Center(
              child: Text(
                'Daftar Stok Vaksinasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Content / Listing Kartu Vaksin
          Expanded(
            child: Obx(() {
              if (controller.vaksinList.isEmpty && controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.vaksinList.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada data vaksin.',
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.vaksinList.length,
                itemBuilder: (context, index) {
                  final vaksin = controller.vaksinList[index];
                  return _UserVaksinCard(
                    vaksin: vaksin,
                    informasiChildren: _buildInformasi(vaksin),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInformasi(Vaksin vaksin) {
    if (vaksin.informasi.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'Belum ada informasi tambahan untuk vaksin ini.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
      ];
    }

    return vaksin.informasi
        .where((k) => k.subjudul.isNotEmpty || k.isi.isNotEmpty)
        .map((k) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (k.subjudul.isNotEmpty)
                    Text(
                      k.subjudul,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  if (k.isi.isNotEmpty)
                    Text(
                      k.isi,
                      style: const TextStyle(fontSize: 13),
                    ),
                ],
              ),
            ))
        .toList();
  }
}

/// Custom Card Widget Presisi
class _UserVaksinCard extends StatefulWidget {
  final Vaksin vaksin;
  final List<Widget> informasiChildren;

  const _UserVaksinCard({
    required this.vaksin,
    required this.informasiChildren,
  });

  @override
  State<_UserVaksinCard> createState() => _UserVaksinCardState();
}

class _UserVaksinCardState extends State<_UserVaksinCard> {
  bool _isExpanded = false;

  Color get _accentColor {
    switch (widget.vaksin.statusStok) {
      case 'tersedia':
        return const Color(0xFF52C49C);
      case 'menipis':
        return const Color(0xFFF1B44C);
      default:
        return const Color(0xFFE57373);
    }
  }

  Color get _bgColor {
    switch (widget.vaksin.statusStok) {
      case 'tersedia':
        return const Color(0xFFE8F7F2);
      case 'menipis':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFFFEBEE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringkasan = widget.vaksin.informasi.isNotEmpty
        ? widget.vaksin.informasi.first.subjudul
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _accentColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Kartu (Nama Vaksin & Tombol Lihat Detail)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.vaksin.namaVaksin,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
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
                  ],
                ),
              ),

              // 2. Garis Pemisah (Divider)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withOpacity(0.15),
              ),

              // 3. Konten Utama Card
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
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
                    ] else if (widget.vaksin.kategoriVaksin.isNotEmpty) ...[
                      Text(
                        widget.vaksin.kategoriVaksin,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      'Stok : ${widget.vaksin.jumlahStok}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Status : ${widget.vaksin.statusLabel}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Detail tambahan saat kartu diklik
              if (_isExpanded) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black.withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                ...widget.informasiChildren,
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}