import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Bumped whenever `slips.json` is rewritten or deleted, so screens showing
/// slips (dashboard, plan) can reload instead of going stale.
final ValueNotifier<int> slipsRevision = ValueNotifier<int>(0);

Future<File> _slipsFile() async {
  final appDir = await getApplicationDocumentsDirectory();
  return File('${appDir.path}/slips.json');
}

/// Reads whatever is already saved in `slips.json` without touching the
/// filesystem folders or running OCR. Use this on screen load so the
/// dashboard shows something instantly, before the user taps refresh.
Future<List<Map<String, dynamic>>> loadSavedSlips() async {
  final jsonFile = await _slipsFile();

  if (!await jsonFile.exists()) return [];

  try {
    final content = await jsonFile.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    return List<Map<String, dynamic>>.from(jsonList);
  } catch (_) {
    return [];
  }
}

/// Overwrites `slips.json` with [records].
Future<void> saveSlips(List<Map<String, dynamic>> records) async {
  final jsonFile = await _slipsFile();
  await jsonFile.writeAsString(jsonEncode(records), mode: FileMode.write);
  slipsRevision.value++;
}

/// Deletes `slips.json`. The slip images themselves are left untouched, so
/// the next refresh will read them again.
Future<void> clearSavedSlips() async {
  final jsonFile = await _slipsFile();

  if (await jsonFile.exists()) {
    await jsonFile.delete();
  }
  slipsRevision.value++;
}

/// Parses a slip's `amount` (e.g. "1,500.00") into a number, or null when
/// OCR found nothing ("Not Found").
double? amountOf(Map<String, dynamic> slip) {
  return double.tryParse((slip['amount'] ?? '').toString().replaceAll(',', ''));
}
