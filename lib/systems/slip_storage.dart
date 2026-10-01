import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
}

/// Deletes `slips.json`. The slip images themselves are left untouched, so
/// the next refresh will read them again.
Future<void> clearSavedSlips() async {
  final jsonFile = await _slipsFile();

  if (await jsonFile.exists()) {
    await jsonFile.delete();
  }
}
