import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';
import 'package:moneyplus_material/screens/plan_tab.dart';
import 'package:moneyplus_material/systems/slip_storage.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('plan_tab_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    File('${tempDir.path}/slips.json').writeAsStringSync(
      jsonEncode([
        {
          'imagePath': '/a.png',
          'amount': '1,000.00',
          'txTime': '2026-10-02T10:00:00.000',
          'Bank': 'K PLUS',
        },
        {
          'imagePath': '/b.png',
          'amount': 'Not Found',
          'txTime': '2026-10-01T10:00:00.000',
          'Bank': 'SCB Easy',
        },
      ]),
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('create a goal and assign a detected slip to it', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('th'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanTab(),
      ),
    );
    await settle(tester);

    expect(find.text('พบสลีปใหม่ 1 รายการ'), findsOneWidget);
    expect(find.text('เพิ่มเป้าหมาย'), findsOneWidget);

    await tester.tap(find.text('เพิ่มเป้าหมาย'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'ทริปญี่ปุ่น');
    await tester.enterText(find.byType(TextFormField).at(1), '10000');
    await tester.tap(find.text('สร้าง'));
    await settle(tester);

    expect(find.text('ทริปญี่ปุ่น'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('฿0 / ฿10,000'), findsOneWidget);

    await tester.tap(find.text('พบสลีปใหม่ 1 รายการ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('K PLUS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ทริปญี่ปุ่น').last);
    await settle(tester);

    expect(find.text('10%'), findsOneWidget);
    expect(find.text('฿1,000 / ฿10,000'), findsOneWidget);
    expect(find.textContaining('พบสลีปใหม่'), findsNothing);
  });

  testWidgets('goal form rejects empty input', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('th'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanTab(),
      ),
    );
    await settle(tester);

    await tester.tap(find.text('เพิ่มเป้าหมาย'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('สร้าง'));
    await tester.pumpAndSettle();

    expect(find.text('กรุณากรอกชื่อเป้าหมาย'), findsOneWidget);
    expect(find.text('กรุณากรอกจำนวนเงินให้ถูกต้อง'), findsOneWidget);
  });

  testWidgets('tapping a goal shows its detail and it can be deleted', (
    tester,
  ) async {
    File('${tempDir.path}/goals.json').writeAsStringSync(
      jsonEncode([
        {
          'id': '1',
          'name': 'ทริปญี่ปุ่น',
          'target': 10000.0,
          'payments': [
            {'imagePath': '/a.png', 'amount': 1000.0},
          ],
        },
      ]),
    );

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('th'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanTab(),
      ),
    );
    await settle(tester);

    expect(find.textContaining('พบสลีปใหม่'), findsNothing);

    await tester.tap(find.text('ทริปญี่ปุ่น'));
    await tester.pumpAndSettle();

    expect(find.text('เหลืออีก ฿9,000'), findsOneWidget);
    expect(find.text('รายการที่จ่าย (1)'), findsOneWidget);

    await tester.tap(find.text('ลบเป้าหมาย'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบ'));
    await settle(tester);

    expect(find.text('ทริปญี่ปุ่น'), findsNothing);
    expect(find.text('พบสลีปใหม่ 1 รายการ'), findsOneWidget);
  });

  testWidgets('detected slips follow the saved slip list', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('th'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlanTab(),
      ),
    );
    await settle(tester);

    expect(find.text('พบสลีปใหม่ 1 รายการ'), findsOneWidget);

    await tester.runAsync(clearSavedSlips);
    await settle(tester);

    expect(find.textContaining('พบสลีปใหม่'), findsNothing);
  });
}
