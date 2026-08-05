import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../controllers/anak_controller.dart';
import '../../controllers/jadwal_master_controller.dart';
import '../../controllers/jadwal_controller.dart';
import '../../controllers/vaksin_controller.dart';
import '../../controllers/artikel_controller.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../models/anak_model.dart';
import '../../models/artikel_model.dart';
import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../services/jadwal_schedule_service.dart';
import '../../utils/date_formatter.dart';
import 'anak/tambah_anak_user_page.dart';
import 'anak/anak_saya_jadwal_page.dart';
import 'anak/anak_saya_list_page.dart';
import 'artikel/user_artikel_list_page.dart';
import 'artikel/user_artikel_detail_page.dart';
import 'hubungi_klinik/hubungi_klinik_page.dart';
import '../notification/notifikasi_page.dart';
import 'profile/profil_anda_page.dart';

class UserDashboardHome extends StatefulWidget {
  const UserDashboardHome({super.key});

  @override
  State<UserDashboardHome> createState() => _UserDashboardHomeState();
}

class _UserDashboardHomeState extends State<UserDashboardHome> {
  NotificationSettings? _notificationSettings;
  int _selectedAnakIndex = 0;
  late final NotifikasiController _notifikasiController;

  @override
  void initState() {
    super.initState();
    _notifikasiController = Get.put(NotifikasiController());
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final settings = await FcmService().getNotificationSettings();
    if (mounted) {
      setState(() {
        _notificationSettings = settings;
      });
    }
  }

  bool get _showPermissionBanner {
    final status = _notificationSettings?.authorizationStatus;
    return status != null && status != AuthorizationStatus.authorized;
  }

  Future<void> _requestNotificationPermission() async {
    await FcmService().requestPermissionIfNeeded();
    await _loadNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    final anakController = Get.put(AnakController());
    final masterController = Get.put(JadwalMasterController());
    final jadwalController = Get.put(JadwalController());
    final vaksinController = Get.put(VaksinController());
    final artikelController = Get.put(ArtikelController());
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: SafeArea(
        child: Obx(() {
          final anakSaya = anakController.anakList.where((a) => a.idUser == uid).toList();
          final selectedAnak = anakSaya.isNotEmpty
              ? anakSaya[_selectedAnakIndex.clamp(0, anakSaya.length - 1)]
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              if (_showPermissionBanner)
                _buildNotificationPermissionBanner(context),
              const Text('Profil Anak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (anakSaya.isEmpty)
                _buildEmptyState(context)
              else ...[
                _buildAnakSelector(anakSaya),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AnakBlock(
                    index: _selectedAnakIndex,
                    anak: selectedAnak!,
                    masterController: masterController,
                    jadwalController: jadwalController,
                    vaksinController: vaksinController,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TambahAnakUserPage()),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Tambah Profil Anak'),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              _buildMenuGrid(context, anakSaya),
              const SizedBox(height: 24),
              _buildArtikelSection(context, artikelController),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNotificationPermissionBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktifkan notifikasi',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          const Text(
            'Supaya pengingat imunisasi muncul di status bar, izinkan notifikasi sekarang.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange.shade400),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _requestNotificationPermission,
                  child: const Text('Izinkan Notifikasi'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: const Text('Nanti'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final controller = _notifikasiController;
    return Row(
      children: [
        const Icon(Icons.favorite, color: Colors.teal, size: 28),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'MediKidz',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ),
        Obx(() {
          final unread = controller.unreadCount.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.teal.withValues(alpha: 0.1),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.teal, size: 20),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotifikasiPage()),
                  ),
                ),
              ),
              if (unread > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53E3E),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread > 99 ? '99+' : unread.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.teal.withValues(alpha: 0.1),
          child: IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.teal, size: 20),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilAndaPage()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.child_friendly, size: 56, color: Colors.teal),
          const SizedBox(height: 12),
          const Text(
            'Daftarkan profil anak untuk cek jadwal imunisasi!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TambahAnakUserPage()),
              ),
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text('Tambah Profil Anak', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnakSelector(List<Anak> anakSaya) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2F8D7E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Anak ${_selectedAnakIndex + 1}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2F8D7E)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedAnakIndex.clamp(0, anakSaya.length - 1),
                items: anakSaya.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value.namaAnak),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAnakIndex = value;
                    });
                  }
                },
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2F8D7E)),
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context, List<Anak> anakSaya) {
    Widget item(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.teal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onTap,
            child: Column(
              children: [
                CircleAvatar(radius: 20, backgroundColor: Colors.teal.withValues(alpha: 0.12), child: Icon(icon, color: Colors.teal)),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    void bukaJadwalAtauRiwayat() {
      if (anakSaya.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tambahkan profil anak dulu untuk melihat jadwal imunisasi.')),
        );
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnakSayaListPage()));
    }

    return Column(
      children: [
        Row(children: [
          item(Icons.calendar_month_outlined, 'Jadwal\nImunisasi', bukaJadwalAtauRiwayat),
          item(Icons.assignment_outlined, 'Riwayat\nImunisasi', bukaJadwalAtauRiwayat),
        ]),
        Row(children: [
          item(Icons.favorite_border, 'Tips Medis', () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserArtikelListPage()),
              )),
          item(Icons.support_agent, 'Hubungi\nKlinik', () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HubungiKlinikPage()),
              )),
        ]),
      ],
    );
  }

  Widget _buildArtikelSection(BuildContext context, ArtikelController artikelController) {
    return Obx(() {
      final artikelList = artikelController.artikelList
          .where((a) => a.status == 'dipublikasi')
          .take(5)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Artikel Kesehatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserArtikelListPage()),
                ),
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          if (artikelList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Belum ada artikel.', style: TextStyle(color: Colors.black54)),
            )
          else
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: artikelList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _ArtikelCard(artikel: artikelList[i]),
              ),
            ),
        ],
      );
    });
  }
}

class _ArtikelCard extends StatelessWidget {
  final Artikel artikel;
  const _ArtikelCard({required this.artikel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => UserArtikelDetailPage(artikel: artikel)),
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: artikel.gambarUrl != null && artikel.gambarUrl!.isNotEmpty
                  ? Image.network(artikel.gambarUrl!, height: 80, width: double.infinity, fit: BoxFit.cover)
                  : Container(height: 80, color: Colors.teal.withValues(alpha: 0.1), child: const Icon(Icons.description_outlined, color: Colors.teal)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(artikel.kategori, style: const TextStyle(fontSize: 9, color: Colors.teal)),
                  ),
                  const SizedBox(height: 4),
                  Text(artikel.judul, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blok profil 1 anak: kartu info anak + kartu "Imunisasi Berikutnya".
class _AnakBlock extends StatefulWidget {
  final int index;
  final Anak anak;
  final JadwalMasterController masterController;
  final JadwalController jadwalController;
  final VaksinController vaksinController;

  const _AnakBlock({
    required this.index,
    required this.anak,
    required this.masterController,
    required this.jadwalController,
    required this.vaksinController,
  });

  @override
  State<_AnakBlock> createState() => _AnakBlockState();
}

class _AnakBlockState extends State<_AnakBlock> {
  bool _expanded = false;
  final _scheduleService = JadwalScheduleService();

  String _hitungUsia(DateTime tanggalLahir) {
    final now = DateTime.now();
    var bulan = (now.year - tanggalLahir.year) * 12 + (now.month - tanggalLahir.month);
    if (now.day < tanggalLahir.day) bulan -= 1;
    if (bulan < 0) bulan = 0;
    final tahun = bulan ~/ 12;
    final sisaBulan = bulan % 12;
    if (tahun == 0) return '$sisaBulan Bulan';
    if (sisaBulan == 0) return '$tahun Tahun';
    return '$tahun Tahun $sisaBulan Bulan';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final jadwal = _scheduleService.computeJadwalForAnak(
        anak: widget.anak,
        masterList: widget.masterController.jadwalMasterList,
        semuaJadwalImunisasi: widget.jadwalController.jadwalList,
      );

      final belumSelesai = jadwal.where((j) => !j.sudah).toList()
        ..sort((a, b) => a.tanggalJadwal.compareTo(b.tanggalJadwal));

      final berikutnya = belumSelesai.isEmpty ? null : belumSelesai.first;
      final sisanya = belumSelesai.length > 1 ? belumSelesai.skip(1).take(3).toList() : <dynamic>[];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu info anak
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AnakSayaJadwalPage(anak: widget.anak)),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.teal.withOpacity(0.12),
                    child: Icon(widget.anak.jenisKelamin == 'laki-laki' ? Icons.boy : Icons.girl, color: Colors.teal, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.anak.namaAnak, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Usia: ${_hitungUsia(widget.anak.tanggalLahir)}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 2),
                        Text('NIK: ${widget.anak.nik ?? '-'}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Kartu Imunisasi Berikutnya
          if (berikutnya == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(child: Text('Semua imunisasi terjadwal sudah lengkap!')),
                ],
              ),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.teal.shade500, Colors.teal.shade800]),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.campaign_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Imunisasi Berikutnya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _baris('Vaksin', berikutnya.master.namaVaksin),
                  _baris('Perkiraan', _formatDate(berikutnya.tanggalJadwal)),
                  _baris('Stok Vaksin', '${_cariStok(berikutnya.master.namaVaksin)}'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          berikutnya.statusLabel == 'Terlambat' ? 'Status: Terlambat' : 'Status: Belum Dilakukan',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Icon(
                          berikutnya.statusLabel == 'Terlambat' ? Icons.warning_amber_rounded : Icons.circle,
                          size: berikutnya.statusLabel == 'Terlambat' ? 18 : 10,
                          color: berikutnya.statusLabel == 'Terlambat' ? Colors.amber : Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DeadlineCountdown(target: berikutnya.tanggalJadwal),
                ],
              ),
            ),
            if (berikutnya.statusLabel == 'Terlambat') ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Penting: Segera hubungi klinik untuk penjadwalan ulang.',
                        style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          if (sisanya.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Lihat Selengkapnya', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.teal),
                  ],
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: sisanya.map((j) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.schedule, color: Colors.orange),
                        title: Text('${j.master.namaVaksin} - Dosis ${j.master.urutanDosis}'),
                        subtitle: Text(_formatDate(j.tanggalJadwal)),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ],
      );
    });
  }

  int _cariStok(String namaVaksin) {
    try {
      return widget.vaksinController.vaksinList
          .firstWhere((v) => v.namaVaksin.toLowerCase() == namaVaksin.toLowerCase())
          .jumlahStok;
    } catch (_) {
      return 0;
    }
  }

  Widget _baris(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => formatTanggal(date);
}

/// Hitung mundur waktu ke tanggal jadwal (D:HH:MM:SS). Kalau sudah lewat,
/// tampilkan "Terlambat" -- bukan angka minus.
class _DeadlineCountdown extends StatefulWidget {
  final DateTime target;
  const _DeadlineCountdown({required this.target});

  @override
  State<_DeadlineCountdown> createState() => _DeadlineCountdownState();
}

class _DeadlineCountdownState extends State<_DeadlineCountdown> {
  Timer? _timer;
  Duration _sisa = Duration.zero;

  @override
  void initState() {
    super.initState();
    _hitung();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _hitung());
  }

  void _hitung() {
    final now = DateTime.now();
    final diff = widget.target.difference(now);
    if (mounted) setState(() => _sisa = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.target.isBefore(DateTime.now())) {
      return const Text('Deadline Imunisasi: Terlambat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600));
    }

    final hari = _sisa.inDays;
    final jam = _sisa.inHours % 24;
    final menit = _sisa.inMinutes % 60;
    final detik = _sisa.inSeconds % 60;
    final teks =
        '$hari:${jam.toString().padLeft(2, '0')}:${menit.toString().padLeft(2, '0')}:${detik.toString().padLeft(2, '0')}';

    return Text('Deadline Imunisasi: $teks', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600));
  }
}
