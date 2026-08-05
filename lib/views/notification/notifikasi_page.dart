import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/anak_controller.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../models/anak_model.dart';
import '../../models/notifikasi_model.dart';

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
    if (diff.inHours < 1) return '${diff.inMinutes} menit yang lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
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
        return const Color(0xFF6B46C1);
      case 'akun':
        return const Color(0xFF2D9580);
      case 'jadwal':
        return const Color(0xFF0EA5E9);
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.adminMode ? 'Notifikasi Admin' : 'Notifikasi',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: widget.adminMode
            ? [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black87),
                  onPressed: _showCreateDialog,
                ),
              ]
            : null,
      ),
      body: Obx(() {
        final items = widget.adminMode
            ? _adminController?.notifikasiList ?? []
            : _userController?.notifikasiList ?? [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada notifikasi',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notifikasi = items[index];
              return _buildCard(context, notifikasi);
            },
          ),
        );
      }),
      floatingActionButton: widget.adminMode
          ? FloatingActionButton.extended(
              onPressed: _showCreateDialog,
              label: const Text('Tambah Notifikasi'),
              icon: const Icon(Icons.add),
              backgroundColor: const Color(0xFF2D9580),
            )
          : FloatingActionButton.extended(
              onPressed: _userController?.markAllRead,
              label: const Text('Tandai semua dibaca'),
              icon: const Icon(Icons.done_all),
              backgroundColor: const Color(0xFF2D9580),
            ),
    );
  }

  Widget _buildCard(BuildContext context, Notifikasi notifikasi) {
    final color = _colorForKategori(notifikasi.kategori);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconForKategori(notifikasi.kategori), color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    notifikasi.judul,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                if (!notifikasi.terbaca)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53E3E),
                      shape: BoxShape.circle,
                    ),
                  ),
                if (widget.adminMode)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.edit, color: Colors.blue.shade700, size: 20),
                        onPressed: () => _showEditDialog(notifikasi),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.delete, color: Colors.red.shade700, size: 20),
                        onPressed: () => _confirmDelete(context, notifikasi),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notifikasi.pesan,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
            if (widget.adminMode) ...[
              const SizedBox(height: 12),
              Text(
                'UID: ${notifikasi.uid}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              Text(
                notifikasi.terbaca ? 'Status: dibaca' : 'Status: belum dibaca',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              _formatWaktu(notifikasi.waktu),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
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
          title: const Text('Tambah Notifikasi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pesanController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Pesan'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: kategori,
                  items: const [
                    DropdownMenuItem(value: 'umum', child: Text('Umum')),
                    DropdownMenuItem(value: 'artikel', child: Text('Artikel')),
                    DropdownMenuItem(value: 'akun', child: Text('Akun')),
                    DropdownMenuItem(value: 'jadwal', child: Text('Jadwal')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      kategori = value;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Semua pengguna'),
                                selected: !targetSingle,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      targetSingle = false;
                                      selectedUserId = null;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Satu pengguna'),
                                selected: targetSingle,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      targetSingle = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                                if (targetSingle)
                          Obx(() {
                            final anakList = _anakController?.anakList ?? <Anak>[];
                            return DropdownButtonFormField<String>(
                              initialValue: selectedUserId,
                              decoration: const InputDecoration(labelText: 'Pilih nama anak'),
                              items: anakList
                                  .map(
                                    (anak) => DropdownMenuItem(
                                      value: anak.id,
                                      child: Text(anak.namaAnak),
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
                        const SizedBox(height: 12),
                        Text(
                          targetSingle
                              ? 'Notifikasi ini hanya akan dikirim ke pengguna terpilih.'
                              : 'Notifikasi ini akan dikirim ke semua pengguna.',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            Obx(() {
              final submitting = _adminController!.isSubmitting.value;
              return ElevatedButton(
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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Kirim'),
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
          title: const Text('Edit Notifikasi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pesanController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Pesan'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: kategori,
                  items: const [
                    DropdownMenuItem(value: 'umum', child: Text('Umum')),
                    DropdownMenuItem(value: 'artikel', child: Text('Artikel')),
                    DropdownMenuItem(value: 'akun', child: Text('Akun')),
                    DropdownMenuItem(value: 'jadwal', child: Text('Jadwal')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      kategori = value;
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
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
              child: const Text('Simpan'),
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
          title: const Text('Hapus Notifikasi'),
          content: const Text('Apakah Anda yakin ingin menghapus notifikasi ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
