const List<String> _thaiMonthsAbbr = [
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.',
];

/// Formats [dt] as e.g. `2 ต.ค. 2569` (abbreviated month, Buddhist year).
String formatThaiDate(DateTime dt) {
  final buddhistYear = dt.year + 543;
  final month = _thaiMonthsAbbr[dt.month - 1];
  return '${dt.day} $month $buddhistYear';
}
