import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/artikel_controller.dart';
import '../../../models/artikel_model.dart';
import '../widgets/admin_header.dart';
import 'artikel_form_page.dart';

class ArtikelListPage extends StatefulWidget {
  const ArtikelListPage({super.key});

  @override
  State<ArtikelListPage> createState() => _ArtikelListPageState();
}

class _ArtikelListPageState extends State<ArtikelListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'semua'; // semua | draft | dipublikasi | arsip

  static const _primaryTeal = Color(0xFF38B2AC);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtikelController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: buildMedikidzHeaderAppBar(),
      body: Obx(() {
        final semuaArtikel = controller.artikelList;

        var artikelTampil = semuaArtikel.where((a) {
          final cocokFilter = _filterStatus == 'semua' || a.status == _filterStatus;
          final q = _searchQuery.toLowerCase();
          final cocokCari = q.isEmpty ||
              a.judul.toLowerCase().contains(q) ||
              a.kategori.toLowerCase().contains(q) ||
              a.penulis.toLowerCase().contains(q);
          return cocokFilter && cocokCari;
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildPageHeader(context),
            const SizedBox(height: 16),
            _buildSearchAndFilter(context),
            const SizedBox(height: 16),
            _buildStatsRow(semuaArtikel),
            const SizedBox(height: 16),

            if (controller.artikelList.isEmpty && controller.isLoading.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (artikelTampil.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('Tidak ada artikel yang cocok.')),
              )
            else
              ...artikelTampil.map((a) => _ArtikelCard(
                    artikel: a,
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ArtikelFormPage(artikel: a)),
                    ),
                    onDelete: () => _confirmDelete(context, controller, a.id!),
                  )),
          ],
        );
      }),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Artikel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('Kelola semua Artikel pada aplikasi',
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ArtikelFormPage()),
          ),
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text('Tambah Artikel', style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Cari artikel, kategori, atau penulis...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryTeal,
            side: BorderSide(color: _primaryTeal.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _openFilterSheet(context),
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filter'),
        ),
      ],
    );
  }

  Widget _buildStatsRow(List<Artikel> semuaArtikel) {
    final total = semuaArtikel.length;
    final dipublikasi = semuaArtikel.where((a) => a.status == 'dipublikasi').length;
    final draft = semuaArtikel.where((a) => a.status == 'draft').length;
    final arsip = semuaArtikel.where((a) => a.status == 'arsip').length;

    return Row(
      children: [
        _StatChip(icon: Icons.description_outlined, iconColor: Colors.teal, value: total, label: 'Total Artikel'),
        _StatChip(icon: Icons.send_outlined, iconColor: Colors.orange, value: dipublikasi, label: 'Dipublikasi'),
        _StatChip(icon: Icons.edit_note, iconColor: Colors.grey, value: draft, label: 'Draft'),
        _StatChip(icon: Icons.delete_outline, iconColor: Colors.red, value: arsip, label: 'Arsip'),
      ],
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String value, void Function(void Function()) setModalState) {
    final selected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setModalState(() {});
        setState(() => _filterStatus = value);
      },
    );
  }

  void _confirmDelete(BuildContext context, ArtikelController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
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

  const _StatChip({required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 14, backgroundColor: iconColor.withOpacity(0.12), child: Icon(icon, size: 15, color: iconColor)),
            const SizedBox(height: 6),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.black54), textAlign: TextAlign.center),
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

  const _ArtikelCard({required this.artikel, required this.onEdit, required this.onDelete});

  Color get _statusColor {
    switch (artikel.status) {
      case 'dipublikasi':
        return Colors.teal;
      case 'arsip':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: artikel.gambarUrl != null
                ? Image.network(artikel.gambarUrl!, width: 76, height: 76, fit: BoxFit.cover)
                : Container(
                    width: 76,
                    height: 76,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(artikel.kategori,
                          style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(artikel.statusLabel,
                          style: TextStyle(fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.teal),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 6),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 17, color: Colors.red),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 4),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(artikel.judul,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${_formatTanggal(artikel.tanggalUpload)}  •  Penulis: ${artikel.penulis}',
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTanggal(DateTime date) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }
}
