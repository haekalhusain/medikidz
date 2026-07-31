import 'package:flutter/material.dart';
import '../../../models/jadwal_master_model.dart';
import '../../../services/jadwal_schedule_service.dart';

/// Kolom usia untuk matriks 0-24 bulan. Nilai `hari` HARUS cocok persis
/// dengan usia_hari yang dipakai saat generate tb_jadwalMaster
/// (30 hari/bulan), supaya tiap dosis jatuh tepat di kolom yang benar.
const _kolomUsia = [
  (hari: 0, label: 'Lahir'),
  (hari: 30, label: '1'),
  (hari: 60, label: '2'),
  (hari: 90, label: '3'),
  (hari: 120, label: '4'),
  (hari: 150, label: '5'),
  (hari: 180, label: '6'),
  (hari: 270, label: '9'),
  (hari: 360, label: '12'),
  (hari: 450, label: '15'),
  (hari: 540, label: '18'),
  (hari: 720, label: '24'),
];

/// Kategori dosis untuk pewarnaan sel, mengikuti konvensi tabel IDAI:
/// hijau = dosis primer, biru = booster, pink = khusus (mis. JE),
/// kuning = overlay saat status realisasi pasien "Terlambat" (catch-up).
///
/// CATATAN: JadwalMaster belum punya field kategori dosis eksplisit,
/// jadi ini pakai HEURISTIK (dosis terakhir + usia >=12 bulan = booster,
/// nama mengandung "Japanese" = khusus). Kalau butuh presisi medis
/// yang lebih akurat, tambahkan field `kategori_dosis` yang bisa
/// diedit admin di tb_jadwalMaster (pola sama seperti toleransi
/// keterlambatan yang sudah ada).
String _kategoriDosis(JadwalMaster m, List<JadwalMaster> semuaDosisVaksinIni) {
  if (m.namaVaksin.toLowerCase().contains('japanese')) return 'khusus';
  if (semuaDosisVaksinIni.length > 1) {
    final dosisTerakhir =
        semuaDosisVaksinIni.map((d) => d.urutanDosis).reduce((a, b) => a > b ? a : b);
    if (m.urutanDosis == dosisTerakhir && m.usiaHari >= 360) return 'booster';
  }
  return 'primer';
}

Color _warnaKategori(String kategori) {
  switch (kategori) {
    case 'booster':
      return Colors.blue.shade200;
    case 'khusus':
      return Colors.pink.shade100;
    default:
      return Colors.green.shade200;
  }
}

class JadwalMatrixWidget extends StatelessWidget {
  final List<JadwalTerjadwal> jadwal; // hasil computeJadwalForAnak, SUDAH termasuk seluruh usia

  const JadwalMatrixWidget({super.key, required this.jadwal});

  @override
  Widget build(BuildContext context) {
    // Cuma ambil dosis yang jatuh dalam rentang 0-24 bulan (usia_hari <= 720)
    final jadwal24Bulan = jadwal.where((j) => j.master.usiaHari <= 720).toList();

    // Kelompokkan per nama vaksin, urut sesuai kemunculan pertama
    final namaVaksinUnik = <String>[];
    for (final j in jadwal24Bulan) {
      if (!namaVaksinUnik.contains(j.master.namaVaksin)) namaVaksinUnik.add(j.master.namaVaksin);
    }

    if (namaVaksinUnik.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Belum ada data jadwal master untuk rentang 0-24 bulan.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend(),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            defaultColumnWidth: const FixedColumnWidth(44),
            columnWidths: const {0: FixedColumnWidth(130)},
            children: [
              _buildHeaderRow(),
              for (final nama in namaVaksinUnik)
                _buildVaksinRow(nama, jadwal24Bulan.where((j) => j.master.namaVaksin == nama).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _legendItem(Colors.green.shade200, 'Dosis primer'),
        _legendItem(Colors.blue.shade200, 'Booster'),
        _legendItem(Colors.pink.shade100, 'Khusus'),
        _legendItem(Colors.orange.shade200, 'Terlambat (catch-up)'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.teal.shade700),
      children: [
        const Padding(
          padding: EdgeInsets.all(6),
          child: Text('Imunisasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
        for (final kolom in _kolomUsia)
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              kolom.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
      ],
    );
  }

  TableRow _buildVaksinRow(String namaVaksin, List<JadwalTerjadwal> dosisVaksinIni) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(namaVaksin, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        for (final kolom in _kolomUsia) _buildCell(kolom.hari, dosisVaksinIni),
      ],
    );
  }

  Widget _buildCell(int hariKolom, List<JadwalTerjadwal> dosisVaksinIni) {
    final master = dosisVaksinIni.where((j) => j.master.usiaHari == hariKolom).toList();
    if (master.isEmpty) return const SizedBox(height: 36);

    final j = master.first;
    final kategori = _kategoriDosis(j.master, dosisVaksinIni.map((d) => d.master).toList());
    final warnaDasar = _warnaKategori(kategori);
    final terlambat = !j.sudah && j.statusLabel == 'Terlambat';

    return Container(
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: terlambat ? Colors.orange.shade200 : warnaDasar,
        border: j.sudah ? Border.all(color: Colors.green.shade800, width: 2) : null,
      ),
      child: j.sudah
          ? const Icon(Icons.check, size: 16, color: Colors.green)
          : Text('${j.master.urutanDosis}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
