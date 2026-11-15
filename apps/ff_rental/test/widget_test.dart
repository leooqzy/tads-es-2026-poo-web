import 'package:flutter_test/flutter_test.dart';
import 'package:ff_rental/app.dart';

void main() {
  testWidgets('Exibe a tela de login do FF Rental', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FFRentalApp());

    await tester.pumpAndSettle();

    expect(find.text('FF Rental'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
