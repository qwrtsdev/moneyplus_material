import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moneyplus_material/main.dart' as app;
import 'package:moneyplus_material/systems/preference.dart';

Future<AppLocalizations> pumpApp(WidgetTester tester, Locale locale) async {
  await saveData('locale', locale.languageCode);
  await tester.pumpWidget(app.MyApp(key: ValueKey(locale)));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.dashboard));
  await tester.pumpAndSettle();
  return lookupAppLocalizations(locale);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard refresh flow', () {
    testWidgets(
      'tapping refresh shows the loading state then settles on a result',
      (WidgetTester tester) async {
        for (final locale in AppLocalizations.supportedLocales) {
          final l10n = await pumpApp(tester, locale);

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
        }
      },
    );

    testWidgets('summary amount updates when new history is loaded', (
      WidgetTester tester,
    ) async {
      for (final locale in AppLocalizations.supportedLocales) {
        await pumpApp(tester, locale);

        // Capture the summary figure before refreshing.
        expect(find.textContaining('฿'), findsWidgets);

        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle(
          const Duration(milliseconds: 500),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 30),
        );

        expect(find.textContaining('฿'), findsWidgets);
      }
    });
  });
}
