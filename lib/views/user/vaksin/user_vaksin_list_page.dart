import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/user_header.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';
import 'user_vaksin_detail_page.dart'; // Import halaman detail baru

class UserVaksinListPage extends StatelessWidget {
  const UserVaksinListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VaksinController());

    // Color Palette
    const primaryTeal = Color(0xFF52C49C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(context),
      body: Obx(() {
        if (controller.vaksinList.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // 1. Banner "Informasi Penting"
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFAFAFA),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Penting',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Silakan cek ketersediaan stok vaksin sebelum datang ke klinik.\nStatus stok diperbarui otomatis oleh sistem apotek klinik.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Banner Header "Daftar Stok Vaksinasi" (Sticky)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                primaryTeal: primaryTeal,
              ),
            ),

            // 3. Daftar Kartu Vaksin
            if (controller.vaksinList.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada data vaksin.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vaksin = controller.vaksinList[index];
                      return _UserVaksinCard(
                        vaksin: vaksin,
                      );
                    },
                    childCount: controller.vaksinList.length,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

/// Delegate khusus untuk membuat Banner Header menjadi Sticky
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Color primaryTeal;

  _StickyHeaderDelegate({required this.primaryTeal});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 12,
            color: const Color(0xFFC2E9DC),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: primaryTeal,
            child: const Center(
              child: Text(
                'Daftar Stok Vaksinasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 66.0;

  @override
  double get minExtent => 66.0;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.primaryTeal != primaryTeal;
  }
}

/// Custom Card Widget yang berpindah halaman saat diklik
class _UserVaksinCard extends StatelessWidget {
  final Vaksin vaksin;

  const _UserVaksinCard({
    required this.vaksin,
  });

  Color get _accentColor {
    switch (vaksin.statusStok) {
      case 'tersedia':
        return const Color(0xFF52C49C);
      case 'menipis':
        return const Color(0xFFF1B44C);
      default:
        return const Color(0xFFE57373);
    }
  }

  Color get _bgColor {
    switch (vaksin.statusStok) {
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
    final ringkasan = vaksin.informasi.isNotEmpty
        ? vaksin.informasi.first.subjudul
        : '';

    const fixedGreen = Color(0xFF52C49C);

    // Fungsi untuk berpindah ke Halaman Detail
    void goToDetailPage() {
      Get.to(() => UserVaksinDetailPage(vaksin: vaksin));
    }

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
          onTap: goToDetailPage, // Mengetuk seluruh kartu akan membuka detail
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        vaksin.namaVaksin,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Tombol Lihat Detail
                    GestureDetector(
                      onTap: goToDetailPage, // Mengarahkan ke halaman detail
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: fixedGreen.withValues(alpha: 0.5),
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
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withValues(alpha: 0.15),
              ),
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
                    ] else if (vaksin.kategoriVaksin.isNotEmpty) ...[
                      Text(
                        vaksin.kategoriVaksin,
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
            ],
          ),
        ),
      ),
    );
  }
}