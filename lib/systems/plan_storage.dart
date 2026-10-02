// goal_storage.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> _goalsFile() async {
  final appDir = await getApplicationDocumentsDirectory();
  return File('${appDir.path}/goals.json');
}

/// A goal is `{id, name, target, payments: [{imagePath, amount}]}`. Payments
/// keep their own copy of the amount so goals survive clearing the slip list.
Future<List<Map<String, dynamic>>> loadGoals() async {
  final jsonFile = await _goalsFile();

  if (!await jsonFile.exists()) return [];

  try {
    final content = await jsonFile.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    return List<Map<String, dynamic>>.from(jsonList);
  } catch (_) {
    return [];
  }
}

Future<void> saveGoals(List<Map<String, dynamic>> goals) async {
  final jsonFile = await _goalsFile();
  await jsonFile.writeAsString(jsonEncode(goals), mode: FileMode.write);
}

List<Map<String, dynamic>> goalPayments(Map<String, dynamic> goal) {
  return List<Map<String, dynamic>>.from(goal['payments'] as List? ?? []);
}

double goalSaved(Map<String, dynamic> goal) {
  return goalPayments(goal).fold(
    0.0,
    (sum, payment) => sum + ((payment['amount'] as num?)?.toDouble() ?? 0),
  );
}

double goalTarget(Map<String, dynamic> goal) {
  return (goal['target'] as num?)?.toDouble() ?? 0;
}

/// Share of the goal reached, 0.0 - 1.0.
double goalProgress(Map<String, dynamic> goal) {
  final target = goalTarget(goal);
  if (target <= 0) return 0;
  return (goalSaved(goal) / target).clamp(0.0, 1.0);
}

Map<String, dynamic> newGoal(String name, double target) {
  return {
    'id': DateTime.now().microsecondsSinceEpoch.toString(),
    'name': name,
    'target': target,
    'payments': <Map<String, dynamic>>[],
  };
}
