import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/artikel_controller.dart';
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

    return Scaffold(
      appBar: buildUserTopBar(context),
      body: Column(
        children: [
          // Search & Filter Header Section
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
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Cari artikel kesehatan...',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips Filter
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
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
                        selected: isSelected,
                        selectedColor: Colors.teal,
                        backgroundColor: Colors.white,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() => _selectedKategori = kat);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Article List View
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

class _ArtikelUserCard extends StatelessWidget {
  final Artikel artikel;

  const _ArtikelUserCard({required this.artikel});

  String _formatTanggal(DateTime dt) {
    return formatTanggal(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(() => UserArtikelDetailPage(artikel: artikel));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Cover
            if (artikel.gambarUrl != null && artikel.gambarUrl!.isNotEmpty)
              Image.network(
                artikel.gambarUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                // ignore: unnecessary_underscores
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
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
            ),
          ],
        ),
      ),
    );
  }
}
