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
  final RegExp amountRegex = RegExp(r'(\d{1,3}(?:,\d{3})*\.\d{2})\s*(?:บาท)?');

  try {
    for (File file in filesToProcess) {
      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final match = amountRegex.firstMatch(recognizedText.text);
      final amount = match?.group(1) ?? 'Not Found';

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
