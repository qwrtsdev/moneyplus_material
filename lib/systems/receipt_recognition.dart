// receipt_recognition.dart
import 'dart:convert';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// List of target bank folders inside Android storage
const List<String> kBankFolders = [
  '/storage/emulated/0/Pictures/Krungthai NEXT',
  '/storage/emulated/0/Pictures/Krungsri',
  '/storage/emulated/0/Pictures/K PLUS',
  '/storage/emulated/0/Pictures/SCB Easy',
];

/// Extracts bank name directly from the parent folder containing the image file
String getBankFromFolderName(File file) {
  return file.parent.path.split('/').last;
}

// ---------------------------------------------------------------------------
// Amount extraction
// ---------------------------------------------------------------------------

/// Matches a money value like 1,500.00 / 1500.00 / 50.25
/// - does not depend on "บาท" / "THB"
/// - lookbehind/lookahead avoid matching part of longer numbers or dates (30.09.2026)
final RegExp _moneyRegex = RegExp(
  r'(?<![\d,.])(\d{1,3}(?:,\d{3})+|\d+)\.\d{2}(?!\d|\.\d)',
);

/// Lines that likely hold the transfer amount
final RegExp _amountKeywords = RegExp(
  r'(amount|total|จำนวน|ยอด)',
  caseSensitive: false,
);

/// Lines that must never be treated as the transfer amount
final RegExp _excludeKeywords = RegExp(
  r'(fee|balance|ค่าธรรมเนียม|ค่าบริการ|คงเหลือ)',
  caseSensitive: false,
);

/// Fix common OCR mistakes before matching
String _normalizeLine(String text) {
  return text
      .replaceAll('฿', ' ')
      // 1O0.00 -> 100.00
      .replaceAllMapped(RegExp(r'(?<=\d)[Oo](?=[\d.,])'), (_) => '0');
}

double? _toDouble(String s) => double.tryParse(s.replaceAll(',', ''));

/// Returns the first positive money value in [text], or null.
String? _firstPositiveMoney(String text) {
  for (final m in _moneyRegex.allMatches(text)) {
    final raw = m.group(0)!;
    final v = _toDouble(raw);
    if (v != null && v > 0) return raw;
  }
  return null;
}

/// Extract the transfer amount from ML Kit recognized text.
/// Returns the amount as a string (e.g. "1,500.00") or null if not found.
String? extractAmount(RecognizedText recognized) {
  final lines = recognized.blocks
      .expand((b) => b.lines)
      .map(
        (l) => (
          text: _normalizeLine(l.text.trim()),
          height: l.boundingBox.height,
        ),
      )
      .toList();

  // Pass 1: amount on the same line as a keyword, or on the next line
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].text;
    if (!_amountKeywords.hasMatch(line)) continue;
    if (_excludeKeywords.hasMatch(line)) continue;

    final sameLine = _firstPositiveMoney(line);
    if (sameLine != null) return sameLine;

    if (i + 1 < lines.length &&
        !_excludeKeywords.hasMatch(lines[i + 1].text)) {
      final nextLine = _firstPositiveMoney(lines[i + 1].text);
      if (nextLine != null) return nextLine;
    }
  }

  // Pass 2 (fallback, e.g. keyword not recognized because it is Thai text):
  // among all positive money values on non-fee lines, pick the one printed
  // in the largest text. Slips usually show the amount bigger than anything else.
  String? best;
  double bestHeight = -1;
  for (final line in lines) {
    if (_excludeKeywords.hasMatch(line.text)) continue;
    final money = _firstPositiveMoney(line.text);
    if (money != null && line.height > bestHeight) {
      best = money;
      bestHeight = line.height;
    }
  }
  return best;
}

// ---------------------------------------------------------------------------
// Storage / processing
// ---------------------------------------------------------------------------

/// Reads whatever is already saved in `slips.json` without touching the
/// filesystem folders or running OCR. Use this on screen load so the
/// dashboard shows something instantly, before the user taps refresh.
Future<List<Map<String, dynamic>>> loadSavedSlips() async {
  final appDir = await getApplicationDocumentsDirectory();
  final jsonFile = File('${appDir.path}/slips.json');

  if (!await jsonFile.exists()) return [];

  try {
    final content = await jsonFile.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    return List<Map<String, dynamic>>.from(jsonList);
  } catch (_) {
    return [];
  }
}

/// Deletes `slips.json`. The slip images themselves are left untouched, so
/// the next refresh will read them again.
Future<void> clearSavedSlips() async {
  final appDir = await getApplicationDocumentsDirectory();
  final jsonFile = File('${appDir.path}/slips.json');

  if (await jsonFile.exists()) {
    await jsonFile.delete();
  }
}

/// Single function that scans bank folders, extracts amount via OCR,
/// reads Bank name from folder, and updates 'slips.json'.
///
/// [limit] caps how many *new* files get OCR'd in this call, newest
/// (by last-modified time) first — pass e.g. `limit: 10` while testing so a
/// folder full of old slips doesn't trigger one huge OCR batch. Leave it
/// null in production to process everything unread.
Future<List<Map<String, dynamic>>> processNewSlips({
  List<String> folderPaths = kBankFolders,
  int? limit,
}) async {
  // 1. Request storage permissions
  if (Platform.isAndroid) {
    var status = await Permission.photos.request();
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // 2. Prepare JSON storage file
  final appDir = await getApplicationDocumentsDirectory();
  final jsonFile = File('${appDir.path}/slips.json');

  // 3. Load existing records to filter out already processed images
  List<Map<String, dynamic>> records = [];
  if (await jsonFile.exists()) {
    try {
      final content = await jsonFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      records = List<Map<String, dynamic>>.from(jsonList);
    } catch (_) {}
  }

  final Set<String> processedPaths = records
      .map((e) => e['imagePath'] as String)
      .toSet();

  // 4. Collect unread image files across specified folders
  List<File> unreadFiles = [];

  for (String path in folderPaths) {
    final targetDir = Directory(path);
    if (await targetDir.exists()) {
      final List<File> files = targetDir.listSync().whereType<File>().where((
        file,
      ) {
        final filePath = file.path.toLowerCase();
        final isImage =
            filePath.endsWith('.jpg') ||
            filePath.endsWith('.jpeg') ||
            filePath.endsWith('.png');
        return isImage && !processedPaths.contains(file.path);
      }).toList();
      unreadFiles.addAll(files);
    }
  }

  if (unreadFiles.isEmpty) return records;

  // 4.5 Sort newest-first and cap the batch (testing: limit to latest 10)
  final List<MapEntry<File, DateTime>> filesWithDates = await Future.wait(
    unreadFiles.map((f) async => MapEntry(f, await f.lastModified())),
  );
  filesWithDates.sort((a, b) => b.value.compareTo(a.value));

  final List<File> filesToProcess = limit != null
      ? filesWithDates.take(limit).map((e) => e.key).toList()
      : filesWithDates.map((e) => e.key).toList();

  // 5. Run OCR to get amount and extract Bank name from folder
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  try {
    for (File file in filesToProcess) {
      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final amount = extractAmount(recognizedText) ?? 'Not Found';

      // Read bank directly from directory name (e.g., "Krungthai NEXT", "Krungsri")
      final bank = getBankFromFolderName(file);

      final DateTime fileDate = await file.lastModified();

      records.add({
        'imagePath': file.path,
        'amount': amount,
        'txTime': fileDate.toIso8601String(),
        'Bank': bank,
      });
    }
  } finally {
    await textRecognizer.close();
  }

  // 6. Save updated list to slips.json
  await jsonFile.writeAsString(jsonEncode(records), mode: FileMode.write);

  return records;
}