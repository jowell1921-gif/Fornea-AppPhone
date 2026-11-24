import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/app.dart';

void main() {
  testWidgets('la app arranca y muestra la marca FORNEA', (tester) async {
    await tester.pumpWidget(const ForneaApp());

    expect(find.text('FORNEA'), findsOneWidget);
  });
}
