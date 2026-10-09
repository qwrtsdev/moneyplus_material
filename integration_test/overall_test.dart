import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moneyplus_material/main.dart' as app;
import 'package:moneyplus_material/systems/preference.dart';

Future<AppLocalizations> pumpApp(WidgetTester tester, Locale locale, String screen) async {
  await saveData('locale', locale.languageCode);
  await tester.pumpWidget(app.MyApp(key: ValueKey(locale)));
  await tester.pumpAndSettle();
  if (screen == 'dashboard') {
    await tester.tap(find.byIcon(Icons.dashboard));
  } else if (screen == 'bill') {
    await tester.tap(find.byIcon(Icons.request_quote));
  }
  await tester.pumpAndSettle();
  return lookupAppLocalizations(locale);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard test', () {
    testWidgets(
      'Dashboard refresh works correctly',
      (WidgetTester tester) async {
        for (final locale in AppLocalizations.supportedLocales) {
          final l10n = await pumpApp(tester, locale, 'dashboard');

          expect(find.text(l10n.dashboard_history), findsOneWidget);
          expect(find.byIcon(Icons.refresh), findsOneWidget);

          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();

          expect(find.text(l10n.dashboard_waiting_images), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsWidgets);
          expect(find.byIcon(Icons.refresh), findsNothing);

          await tester.pumpAndSettle(
            const Duration(milliseconds: 500),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 30),
          );

          expect(find.text(l10n.dashboard_waiting_images), findsNothing);
          expect(find.byIcon(Icons.refresh), findsOneWidget);

          final hasHistoryTiles = find.byType(ListTile).evaluate().isNotEmpty;
          final hasEmptyState = find
              .text(l10n.dashboard_history_empty)
              .evaluate()
              .isNotEmpty;
          expect(hasHistoryTiles || hasEmptyState, isTrue, reason: '$locale');
          expect(find.textContaining('฿'), findsWidgets);
        }
      },
    );
  });

  group('Bill test', () {
    testWidgets(
      'Split Bill and QR works correctly',
      (WidgetTester tester) async {
        for (final locale in AppLocalizations.supportedLocales) {
          final l10n = await pumpApp(tester, locale, 'bill');

          await tester.enterText(find.byType(TextField).at(0), '0912345678');
          await tester.enterText(find.byType(TextField).at(1), '10.00');
          await tester.pumpAndSettle();

          await tester.testTextInput.receiveAction(TextInputAction.done);

          await tester.tap(find.text(l10n.bill_split_subtitle));
          await tester.pumpAndSettle();

          final dropdown = find.text(l10n.bill_people_count(2)); 
          await tester.tap(dropdown);
          await tester.pumpAndSettle();

          final dropdownItem = find.text(l10n.bill_people_count(5)); 
          await tester.tap(dropdownItem);
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.bill_generate_qr));
          await tester.pumpAndSettle();

          final listFinder = find.byType(SingleChildScrollView);
          await tester.fling(listFinder, const Offset(0, -100000), 10000);

          expect(find.text(l10n.bill_qr_amount('2.00')), findsOneWidget);
        }
      },
    );
  });
}
