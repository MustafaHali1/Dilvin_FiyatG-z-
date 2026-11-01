import 'package:flutter_test/flutter_test.dart';
import 'package:fiyatgoz/main.dart';

void main() {
  testWidgets('Uygulama acilis testi', (WidgetTester tester) async {
    await tester.pumpWidget(const FiyatGozUygulamasi());
    expect(find.text('Merhaba 👋'), findsOneWidget);
  });
}
