import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/anak_controller.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../models/anak_model.dart';
import '../../models/notifikasi_model.dart';
import 'package:medikidz/views/admin/widgets/admin_header.dart';

class NotifikasiPage extends StatefulWidget {
  final bool adminMode;

  const NotifikasiPage({super.key, this.adminMode = false});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  NotifikasiController? _userController;
  AdminNotifikasiController? _adminController;
  AnakController? _anakController;

  static const Color primaryTeal = Color(0xFF2D9580);
  static const Color bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    if (widget.adminMode) {
      _adminController = Get.put(AdminNotifikasiController());
      _anakController = Get.put(AnakController());
    } else {
      _userController = Get.put(NotifikasiController());
    }
  }

  String _formatWaktu(DateTime waktu) {
    final diff = DateTime.now().difference(waktu);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m yang lalu';
    if (diff.inDays < 1) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}hr yang lalu';
  }

  IconData _iconForKategori(String kategori) {
    switch (kategori) {
      case 'artikel':
        return Icons.article_outlined;
      case 'akun':
        return Icons.person_outline;
      case 'jadwal':
        return Icons.calendar_month_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _colorForKategori(String kategori) {
    switch (kategori) {
      case 'artikel':
        return const Color(0xFF8B5CF6);
      case 'akun':
        return primaryTeal;
      case 'jadwal':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF64748B);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: primaryTeal, size: 20) : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryTeal, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      // Menyembunyikan tombol notifikasi di AppBar khusus untuk halaman ini
      appBar: buildAdminTopBar(context, hideNotification: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
            child: Row(
              children: [
                // Tombol Kembali ke Dashboard
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1E293B),
                    size: 24,
                  ),
                  tooltip: 'Kembali ke Dashboard',
                ),
                const SizedBox(width: 4),
                // Judul Halaman
                Text(
                  widget.adminMode ? 'Notifikasi Admin' : 'Notifikasi',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final items = widget.adminMode
                  ? _adminController?.notifikasiList ?? []
                  : _userController?.notifikasiList ?? [];

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryTeal.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_off_outlined, size: 48, color: primaryTeal),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum Ada Notifikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pesan dan pembaruan akan muncul di sini',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notifikasi = items[index];
                  return _buildCard(context, notifikasi);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: widget.adminMode
          ? FloatingActionButton.extended(
              onPressed: _showCreateDialog,
              label: const Text(
                'Buat Notifikasi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              elevation: 3,
            )
          : FloatingActionButton.extended(
              onPressed: _userController?.markAllRead,
              label: const Text(
                'Tandai Dibaca',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              elevation: 3,
            ),
    );
  }

  Widget _buildCard(BuildContext context, Notifikasi notifikasi) {
    final catColor = _colorForKategori(notifikasi.kategori);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.adminMode
            ? null
            : () {
                if (notifikasi.id != null && !notifikasi.terbaca) {
                  _userController!.markAsRead(notifikasi.id!);
                }
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: !notifikasi.terbaca && !widget.adminMode
                  ? primaryTeal.withAlpha(60)
                  : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconForKategori(notifikasi.kategori), color: catColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notifikasi.kategori.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: catColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatWaktu(notifikasi.waktu),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notifikasi.judul,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notifikasi.terbaca ? FontWeight.w600 : FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!notifikasi.terbaca && !widget.adminMode) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                notifikasi.pesan,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF475569),
                  height: 1.45,
                ),
              ),
              if (widget.adminMode) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UID: ${notifikasi.uid}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notifikasi.terbaca ? 'Status: Dibaca' : 'Status: Belum dibaca',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: notifikasi.terbaca ? primaryTeal : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.edit_outlined, color: Colors.blue.shade600, size: 18),
                          onPressed: () => _showEditDialog(notifikasi),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade600, size: 18),
                          onPressed: () => _confirmDelete(context, notifikasi),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final judulController = TextEditingController();
    final pesanController = TextEditingController();
    var kategori = 'umum';
    var targetSingle = false;
    String? selectedUserId;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryTeal.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_alert_rounded, color: primaryTeal, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Buat Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: judulController,
                  decoration: _inputDecoration('Judul Notifikasi', icon: Icons.title_rounded),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pesanController,
                  maxLines: 3,
                  decoration: _inputDecoration('Pesan Notifikasi', icon: Icons.notes_rounded),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: kategori,
                  menuMaxHeight: 250,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: const [
                    DropdownMenuItem(value: 'umum', child: Text('Umum')),
                    DropdownMenuItem(value: 'artikel', child: Text('Artikel')),
                    DropdownMenuItem(value: 'akun', child: Text('Akun')),
                    DropdownMenuItem(value: 'jadwal', child: Text('Jadwal')),
                  ],
                  onChanged: (value) {
                    if (value != null) kategori = value;
                  },
                  decoration: _inputDecoration('Kategori', icon: Icons.category_outlined),
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Penerima',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Semua'),
                                icon: Icon(Icons.groups_outlined, size: 18),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Satu Orang'),
                                icon: Icon(Icons.person_outline, size: 18),
                              ),
                            ],
                            selected: {targetSingle},
                            onSelectionChanged: (Set<bool> newSelection) {
                              setState(() {
                                targetSingle = newSelection.first;
                                if (!targetSingle) selectedUserId = null;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                (states) => states.contains(WidgetState.selected)
                                    ? primaryTeal.withAlpha(30)
                                    : Colors.grey.shade100,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                        if (targetSingle) ...[
                          const SizedBox(height: 12),
                          Obx(() {
                            final anakList = _anakController?.anakList ?? <Anak>[];
                            return DropdownButtonFormField<String>(
                              initialValue: selectedUserId,
                              isExpanded: true,
                              menuMaxHeight: 250,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              decoration: _inputDecoration('Pilih Anak / User', icon: Icons.child_care_rounded),
                              items: anakList
                                  .map(
                                    (anak) => DropdownMenuItem(
                                      value: anak.id,
                                      child: Text(
                                        anak.namaAnak.isNotEmpty ? anak.namaAnak : 'Tanpa Nama',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedUserId = value;
                                });
                              },
                            );
                          }),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          targetSingle
                              ? 'Notifikasi hanya dikirim ke akun ortu anak terpilih.'
                              : 'Notifikasi dikirim ke seluruh pengguna aplikasi.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            Obx(() {
              final submitting = _adminController!.isSubmitting.value;
              return FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: submitting
                    ? null
                    : () async {
                        final judul = judulController.text.trim();
                        final pesan = pesanController.text.trim();
                        if (judul.isEmpty || pesan.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Judul dan pesan harus diisi.')),
                          );
                          return;
                        }

                        final navigator = Navigator.of(context);
                        if (targetSingle) {
                          if (selectedUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Silakan pilih nama anak terlebih dahulu.')),
                            );
                            return;
                          }
                          final selectedAnak = _anakController?.anakList.firstWhere(
                            (anak) => anak.id == selectedUserId,
                            orElse: () => Anak(
                              id: '',
                              idUser: '',
                              namaAnak: '',
                              tanggalLahir: DateTime.now(),
                              jenisKelamin: 'laki-laki',
                            ),
                          );
                          if (selectedAnak == null || selectedAnak.id?.isEmpty == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Anak tidak ditemukan.')),
                            );
                            return;
                          }
                          await _adminController?.sendToUser(
                            uid: selectedAnak.idUser,
                            judul: judul,
                            pesan: pesan,
                            kategori: kategori,
                          );
                        } else {
                          await _adminController?.createBroadcast(
                            judul: judul,
                            pesan: pesan,
                            kategori: kategori,
                          );
                        }

                        if (!mounted) return;
                        navigator.pop();
                      },
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Kirim', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(Notifikasi notifikasi) async {
    if (!widget.adminMode || notifikasi.id == null) return;

    final judulController = TextEditingController(text: notifikasi.judul);
    final pesanController = TextEditingController(text: notifikasi.pesan);
    var kategori = notifikasi.kategori;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.edit_note_rounded, color: Colors.blue.shade700, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Edit Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: judulController,
                  decoration: _inputDecoration('Judul Notifikasi', icon: Icons.title_rounded),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pesanController,
                  maxLines: 3,
                  decoration: _inputDecoration('Pesan Notifikasi', icon: Icons.notes_rounded),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: kategori,
                  menuMaxHeight: 250,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: const [
                    DropdownMenuItem(value: 'umum', child: Text('Umum')),
                    DropdownMenuItem(value: 'artikel', child: Text('Artikel')),
                    DropdownMenuItem(value: 'akun', child: Text('Akun')),
                    DropdownMenuItem(value: 'jadwal', child: Text('Jadwal')),
                  ],
                  onChanged: (value) {
                    if (value != null) kategori = value;
                  },
                  decoration: _inputDecoration('Kategori', icon: Icons.category_outlined),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final judul = judulController.text.trim();
                final pesan = pesanController.text.trim();
                if (judul.isEmpty || pesan.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Judul dan pesan harus diisi.')),
                  );
                  return;
                }

                final navigator = Navigator.of(context);
                await _adminController?.updateNotification(
                  notifikasi.id!,
                  Notifikasi(
                    id: notifikasi.id,
                    uid: notifikasi.uid,
                    judul: judul,
                    pesan: pesan,
                    kategori: kategori,
                    waktu: notifikasi.waktu,
                    terbaca: notifikasi.terbaca,
                  ),
                );
                if (!mounted) return;
                navigator.pop();
              },
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Notifikasi notifikasi) async {
    if (!widget.adminMode || notifikasi.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Hapus Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus notifikasi ini? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 14),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _adminController!.deleteNotification(notifikasi.id!);
    }
  }
}