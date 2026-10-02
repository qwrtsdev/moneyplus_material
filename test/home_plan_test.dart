import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';
import 'package:moneyplus_material/screens/home_screen.dart';
import 'package:moneyplus_material/systems/slip_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.path);
  final String path;
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  testWidgets('plan tab lists slips saved while another tab was open', (
    tester,
  ) async {
    final dir = Directory.systemTemp.createTempSync('home_plan_test');
    PathProviderPlatform.instance = _FakePathProvider(dir.path);
    SharedPreferences.setMockInitialValues({});

    Future<void> settle() async {
      for (var i = 0; i < 40; i++) {
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump();
      }
    }

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('th'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(),
      ),
    );
    await settle();

    await tester.runAsync(
      () => saveSlips([
        {
          'imagePath': '/a.png',
          'amount': '1,000.00',
          'txTime': '2026-10-02T10:00:00.000',
          'Bank': 'K PLUS',
        },
      ]),
    );
    await settle();
    await tester.tap(find.text('แผน'));
    await settle();
    expect(find.text('พบสลีปใหม่ 1 รายการ'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);

    await tester.runAsync(clearSavedSlips);
    await settle();
    expect(find.textContaining('พบสลีปใหม่'), findsNothing);

    dir.deleteSync(recursive: true);
  });
}
