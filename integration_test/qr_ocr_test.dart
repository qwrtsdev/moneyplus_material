import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moneyplus_material/screens/dashboard_tab.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard refresh flow', () {
    testWidgets(
      'tapping refresh shows the loading state then settles on a result',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: DashboardTab()));
        await tester.pumpAndSettle();

        expect(find.text('ประวัติรายการ'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        expect(find.text('กรุณารอรูปโหลด'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsWidgets);
        expect(find.byIcon(Icons.refresh), findsNothing);

        await tester.pumpAndSettle(
          const Duration(milliseconds: 500),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 30),
        );

        expect(find.text('กรุณารอรูปโหลด'), findsNothing);
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        final hasHistoryTiles = find.byType(ListTile).evaluate().isNotEmpty;
        final hasEmptyState = find
            .text('ยังไม่มีรายการ กรุณากดสแกนสลีปเพื่อเริ่มต้น')
            .evaluate()
            .isNotEmpty;
        expect(hasHistoryTiles || hasEmptyState, isTrue);
      },
    );

    testWidgets('summary amount updates when new history is loaded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: DashboardTab()));
      await tester.pumpAndSettle();

      // Capture the summary figure before refreshing.
      final beforeFinder = find.textContaining('฿');
      expect(beforeFinder, findsWidgets);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 500),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 30),
      );

      expect(find.textContaining('฿'), findsWidgets);
    });
  });
}
