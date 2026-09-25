import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moneyplus_material/main.dart' as app; 

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> startApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
  }

  testWidgets('App opening correctly', (WidgetTester tester) async {
    await startApp(tester);

    final appBarTextFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Dashboard'),
    );
    expect(appBarTextFinder, findsOneWidget);
  });
  
  testWidgets('Bill works correctly', (WidgetTester tester) async {
    await startApp(tester);

    await tester.tap(find.text('Bill'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '0912345678');
    await tester.enterText(find.byType(TextField).at(1), '10.00');
    await tester.pumpAndSettle();

    await tester.testTextInput.receiveAction(TextInputAction.done);

    await tester.tap(find.text('Split Bill'));
    await tester.pumpAndSettle();

    final dropdown = find.text('2 People'); 
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final dropdownItem = find.text('5 People'); 
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generate QR Code'));
    await tester.pumpAndSettle();

    final listFinder = find.byType(SingleChildScrollView);
    await tester.fling(listFinder, const Offset(0, -100000), 10000);

    expect(find.text('Amount: ฿2.00'), findsOneWidget);
  });
}