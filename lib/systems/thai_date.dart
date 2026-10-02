import 'dart:ui';

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

const List<String> _englishMonthsAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats [dt] as e.g. `2 ต.ค. 2569` (abbreviated month, Buddhist year).
String formatThaiDate(DateTime dt) {
  final buddhistYear = dt.year + 543;
  final month = _thaiMonthsAbbr[dt.month - 1];
  return '${dt.day} $month $buddhistYear';
}

/// Formats [dt] as e.g. `2 Oct 2026` (abbreviated month, Gregorian year).
String formatEnglishDate(DateTime dt) {
  final month = _englishMonthsAbbr[dt.month - 1];
  return '${dt.day} $month ${dt.year}';
}

/// Formats [dt] for [locale]: Thai uses [formatThaiDate], anything else
/// falls back to [formatEnglishDate].
String formatDate(DateTime dt, Locale locale) {
  return locale.languageCode == 'th'
      ? formatThaiDate(dt)
      : formatEnglishDate(dt);
}
