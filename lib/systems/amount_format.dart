import 'package:intl/intl.dart';

String formatAmount(num amount, {required int decimalDigits}) {
  final decimals = List.filled(decimalDigits, '0').join();
  final pattern = decimalDigits == 0 ? '#,##0' : '#,##0.$decimals';
  return NumberFormat(pattern, 'en_US').format(amount);
}

String formatAmountText(String amount) {
  final normalized = amount.trim().replaceAll(',', '');
  final value = num.tryParse(normalized);
  if (value == null) return amount;

  final decimalIndex = normalized.indexOf('.');
  final decimalDigits = decimalIndex == -1
      ? 0
      : (normalized.length - decimalIndex - 1).clamp(0, 2);
  return formatAmount(value, decimalDigits: decimalDigits);
}