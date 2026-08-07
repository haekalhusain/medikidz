import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/user_header.dart';
import '../../../controllers/artikel_controller.dart';
import '../../../models/artikel_model.dart';
import '../../../utils/date_formatter.dart';
import 'user_artikel_detail_page.dart';

class UserArtikelListPage extends StatefulWidget {
  const UserArtikelListPage({super.key});

  @override
  State<UserArtikelListPage> createState() => _UserArtikelListPageState();
}

class _UserArtikelListPageState extends State<UserArtikelListPage> {
  final _searchController = TextEditingController();
  String _selectedKategori = 'Semua';
  String _searchQuery = '';

  final List<String> _kategoriList = [
    'Semua',
    'Tips & Tricks',
    'Panduan',
    'Info Vaksin',
    'Tips Kesehatan',
    'Nutrisi Anak',
    'Tumbuh Kembang',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Artikel> _filterArtikel(List<Artikel> articles) {
    return articles.where((artikel) {
      final statusTampil = artikel.status == 'dipublikasi';

      final matchesKategori = _selectedKategori == 'Semua' ||
          artikel.kategori.toLowerCase() == _selectedKategori.toLowerCase();

      final matchesQuery = _searchQuery.isEmpty ||
          artikel.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          artikel.ringkasan.toLowerCase().contains(_searchQuery.toLowerCase());

      return statusTampil && matchesKategori && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtikelController());

    const primaryTeal = Color(0xFF52C49C);
    const lightTealBg = Color(0xFFE8F7F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildUserTopBar(context),
      body: Column(
        children: [
          // Header Search Bar & Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                // 1. Search Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari Artikel...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade500, fontSize: 14),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.grey, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.grey, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Garis Pembatas FULL KIRI-KANAN
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade300,
                ),

                const SizedBox(height: 12),

                // 3. Horizontal Category Chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _kategoriList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final kat = _kategoriList[index];
                      final isSelected = _selectedKategori == kat;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedKategori = kat);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? lightTealBg : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? primaryTeal
                                  : Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            kat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? primaryTeal
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Detail List Artikel
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.artikelList.isEmpty) {
                return const Center(
                    child: CircularProgressIndicator(color: primaryTeal));
              }

              final filteredList = _filterArtikel(controller.artikelList);

              if (filteredList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty || _selectedKategori != 'Semua'
                            ? 'Artikel tidak ditemukan'
                            : 'Belum ada artikel edukasi',
                        style: const TextStyle(
                            fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryTeal,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Section Featured Carousel
                    if (filteredList.isNotEmpty) ...[
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredList.length > 5
                              ? 5
                              : filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return _FeaturedArtikelCard(artikel: item);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Section Daftar Artikel Vertikal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final artikel = filteredList[index];
                          return _ArtikelUserCard(artikel: artikel);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Widget Tampilan Artikel Utama / Featured (Kartu Besar Horizontal)
class _FeaturedArtikelCard extends StatelessWidget {
  final Artikel artikel;

  const _FeaturedArtikelCard({required this.artikel});

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF52C49C);

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => UserArtikelDetailPage(artikel: artikel));
        },
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Gambar Artikel
              Positioned.fill(
                child: artikel.gambarUrl != null &&
                        artikel.gambarUrl!.isNotEmpty
                    ? Image.network(
                        artikel.gambarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.teal.shade100),
                      )
                    : Container(
                        color: Colors.teal.shade100,
                        child: const Icon(Icons.article,
                            size: 48, color: primaryTeal),
                      ),
              ),

              // Overlay Gradient Hitam di Atas Gambar
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),

              // Judul Artikel di Bawah Card
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  artikel.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Tampilan Kartu Artikel Vertikal
class _ArtikelUserCard extends StatelessWidget {
  final Artikel artikel;

  const _ArtikelUserCard({required this.artikel});

  String _formatTanggal(DateTime dt) {
    return formatTanggal(dt);
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF52C49C);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => UserArtikelDetailPage(artikel: artikel));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail di Kiri
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 90,
                  height: 80,
                  color: Colors.teal.shade50,
                  child: artikel.gambarUrl != null &&
                          artikel.gambarUrl!.isNotEmpty
                      ? Image.network(
                          artikel.gambarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                color: primaryTeal, size: 28),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.article,
                              size: 36, color: primaryTeal),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Detail Teks Artikel di Kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artikel.kategori,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Judul Artikel
                    Text(
                      artikel.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tanggal Upload
                    Text(
                      _formatTanggal(artikel.tanggalUpload),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
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