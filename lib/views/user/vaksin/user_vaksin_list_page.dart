import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/user_header.dart';
import '../../../controllers/vaksin_controller.dart';
import '../../../models/vaksin_model.dart';

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
            // 1. Banner "Informasi Penting" -> Ikut ter-scroll & menghilang ke atas
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

            // 2. Banner Header "Daftar Stok Vaksinasi" -> STICKY / MENEMPEL di atas saat discroll
            SliverPersistentHeader(
              pinned: true, // Menjaga header agar tidak hilang/ter-scroll keluar layar
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
                        informasiChildren: _buildInformasi(vaksin),
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
        .map(
          (k) => Padding(
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
                  Text(k.isi, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        )
        .toList();
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

  // Mengubah dari 60.0 ke 66.0 agar pas dengan konten dan tidak overflow
  @override
  double get maxExtent => 66.0;

  @override
  double get minExtent => 66.0;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.primaryTeal != primaryTeal;
  }
}

/// Custom Card Widget
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

    // Warna hijau tetap untuk tombol "Lihat Detail"
    const fixedGreen = Color(0xFF52C49C);

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
                    // Tombol Lihat Detail dengan warna hijau tetap
                    Container(
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
              if (_isExpanded) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.black.withValues(alpha: 0.1),
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