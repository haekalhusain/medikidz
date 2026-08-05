const List<String> _bulanIndonesia = [
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
  'Desember',
];

String formatTanggal(DateTime date) {
  return '${date.day} ${_bulanIndonesia[date.month - 1]} ${date.year}';
}
