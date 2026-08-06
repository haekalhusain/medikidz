import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medikidz/views/notification/notifikasi_page.dart';
import 'package:medikidz/views/user/profile/profil_anda_page.dart';
import '../../../controllers/artikel_controller.dart';
import '../../../controllers/notifikasi_controller.dart'; // 1. Tambahkan import NotifikasiController
import '../../../models/artikel_model.dart';
import '../../../utils/date_formatter.dart';
import '../widgets/user_header.dart';
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

      final matchesKategori =
          _selectedKategori == 'Semua' ||
          artikel.kategori.toLowerCase() == _selectedKategori.toLowerCase();

      final matchesQuery =
          _searchQuery.isEmpty ||
          artikel.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          artikel.ringkasan.toLowerCase().contains(_searchQuery.toLowerCase());

      return statusTampil && matchesKategori && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtikelController());

    // 2. Inisialisasi NotifikasiController
    final notifikasiController = Get.isRegistered<NotifikasiController>()
        ? Get.find<NotifikasiController>()
        : Get.put(NotifikasiController());

    const primaryTeal = Color(0xFF52C49C);
    const lightTealBg = Color(0xFFE8F7F2);

    return Scaffold(
      appBar: buildUserTopBar(context),
      body: Column(
        children: [
          // Header Search Bar & Filter Chips
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                      return ChoiceChip(
                        label: Text(
                          kat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
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
              if (controller.isLoading.value &&
                  controller.artikelList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredList = _filterArtikel(controller.artikelList);

              if (filteredList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty || _selectedKategori != 'Semua'
                            ? 'Artikel tidak ditemukan'
                            : 'Belum ada artikel edukasi',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // Memberikan respon visual saat user melakukan tarik-untuk-refresh
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final artikel = filteredList[index];
                    return _ArtikelUserCard(artikel: artikel);
                  },
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
                  child: const Icon(Icons.broken_image, color: Colors.teal),
                ),
              )
            else
              Container(
                height: 120,
                color: Colors.teal.shade50,
                width: double.infinity,
                child: const Icon(Icons.article, size: 48, color: Colors.teal),
              ),

            // Text Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          artikel.kategori,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.article,
                              size: 36, color: primaryTeal),
                        ),
                      ),
                      Text(
                        _formatTanggal(artikel.tanggalUpload),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    artikel.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    artikel.ringkasan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text(
                        'Baca Selengkapnya',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ],
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
