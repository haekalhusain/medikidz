import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/artikel_controller.dart';
import '../../../models/artikel_model.dart';
import 'artikel_form_page.dart';
import '../profile/profile_page.dart';

class ArtikelListPage extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const ArtikelListPage({super.key, this.onNavigateToTab});

  @override
  State<ArtikelListPage> createState() => _ArtikelListPageState();
}

class _ArtikelListPageState extends State<ArtikelListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'semua'; // semua | draft | dipublikasi | arsip

  // Palette warna sesuai desain
  static const primaryTeal = Color(0xFF00A884);
  static const lightTealBg = Color(0xFFE8F7F2);
  static const filterBg = Color(0xFFE6F7F5);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtikelController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_hospital,
                    color: primaryTeal,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 2),
                Image.asset(
                  'assets/logo2.png',
                  height: 12,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'MediKidz',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          // Icon Profile
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
        final semuaArtikel = controller.artikelList;

        var artikelTampil = semuaArtikel.where((a) {
          final cocokFilter =
              _filterStatus == 'semua' || a.status == _filterStatus;
          final q = _searchQuery.toLowerCase();
          final cocokCari = q.isEmpty ||
              a.judul.toLowerCase().contains(q) ||
              a.kategori.toLowerCase().contains(q) ||
              a.penulis.toLowerCase().contains(q);
          return cocokFilter && cocokCari;
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildPageHeader(context),
            const SizedBox(height: 16),
            _buildSearchAndFilter(context),
            const SizedBox(height: 16),
            _buildStatsRow(semuaArtikel),
            const SizedBox(height: 20),

            if (controller.artikelList.isEmpty && controller.isLoading.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: primaryTeal),
                ),
              )
            else if (artikelTampil.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Tidak ada artikel yang cocok.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...artikelTampil.map((a) => _ArtikelCard(
                    artikel: a,
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => ArtikelFormPage(artikel: a)),
                    ),
                    onDelete: () =>
                        _confirmDelete(context, controller, a.id!),
                  )),
          ],
        );
      }),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (widget.onNavigateToTab != null) {
              widget.onNavigateToTab!(0);
            } else {
              Navigator.maybePop(context);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Artikel',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kelola semua Artikel pada aplikasi',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ArtikelFormPage()),
          ),
          icon: const Icon(Icons.add, size: 16, color: Colors.white),
          label: const Text(
            'Tambah Artikel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Cari artikel, kategori, atau penulis...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => _openFilterSheet(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: filterBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.filter_list_rounded, size: 18, color: primaryTeal),
                SizedBox(width: 6),
                Text(
                  'Filter',
                  style: TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(List<Artikel> semuaArtikel) {
    final total = semuaArtikel.length;
    final dipublikasi =
        semuaArtikel.where((a) => a.status == 'dipublikasi').length;
    final draft = semuaArtikel.where((a) => a.status == 'draft').length;
    final arsip = semuaArtikel.where((a) => a.status == 'arsip').length;

    return Row(
      children: [
        _StatChip(
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF26A69A),
          value: total,
          label: 'Total Artikel',
        ),
        _StatChip(
          icon: Icons.near_me_outlined,
          iconColor: const Color(0xFFFFB74D),
          value: dipublikasi,
          label: 'Dipublikasi',
        ),
        _StatChip(
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF78909C),
          value: draft,
          label: 'Draft',
        ),
        _StatChip(
          icon: Icons.delete_outline,
          iconColor: const Color(0xFFEF5350),
          value: arsip,
          label: 'Arsip',
        ),
      ],
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _filterChip('Semua', 'semua', setModalState),
                    _filterChip('Dipublikasi', 'dipublikasi', setModalState),
                    _filterChip('Draft', 'draft', setModalState),
                    _filterChip('Arsip', 'arsip', setModalState),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value,
      void Function(void Function()) setModalState) {
    final selected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: primaryTeal.withOpacity(0.2),
      onSelected: (_) {
        setModalState(() {});
        setState(() => _filterStatus = value);
      },
    );
  }

  void _confirmDelete(
      BuildContext context, ArtikelController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Yakin ingin menghapus artikel ini?'),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(height: 6),
            // Angka Statistik Lebih Besar & Tebal
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // Teks Label Dibesarkan & Ditebalkan
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtikelCard extends StatelessWidget {
  final Artikel artikel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ArtikelCard({
    required this.artikel,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _statusBgColor {
    switch (artikel.status) {
      case 'dipublikasi':
        return const Color(0xFFE8F7F2);
      case 'arsip':
        return const Color(0xFFFFEBEE);
      default: // draft
        return const Color(0xFFECEFF1);
    }
  }

  Color get _statusTextColor {
    switch (artikel.status) {
      case 'dipublikasi':
        return const Color(0xFF00A884);
      case 'arsip':
        return const Color(0xFFE53935);
      default: // draft
        return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Artikel (105x100 dengan corner radius 12)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: artikel.gambarUrl != null && artikel.gambarUrl!.isNotEmpty
                ? Image.network(
                    artikel.gambarUrl!,
                    width: 105,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          const SizedBox(width: 14),
          // Bagian Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header Dalam Kartu (Kategori, Status Badge, Edit, Delete)
                Row(
                  children: [
                    // Kategori Artikel Dibesarkan Tulisannya
                    Expanded(
                      child: Text(
                        artikel.kategori,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Badge Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        artikel.statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: _statusTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tombol Edit Berjarak
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 17,
                          color: Color(0xFF00A884),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Sampah/Hapus Berjarak
                    InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 17,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Judul Artikel Tebal & Jelas
                Text(
                  artikel.judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                // Tanggal & Penulis Diturunkan Lebih Kebawah
                Text(
                  '${_formatTanggal(artikel.tanggalUpload)}  •  Penulis: ${artikel.penulis}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 105,
      height: 100,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 30),
    );
  }

  String _formatTanggal(DateTime date) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }
}