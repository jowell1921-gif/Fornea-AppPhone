import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/widgets/error_view.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('muestra el mensaje y «Reintentar» llama al callback', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      _wrap(ErrorView(message: 'Sin conexión', onRetry: () => retries++)),
    );

    expect(find.text('Sin conexión'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(retries, 1);
  });

  testWidgets('sin onRetry no muestra el botón', (tester) async {
    await tester.pumpWidget(_wrap(const ErrorView(message: 'Sin conexión')));

    expect(find.text('Reintentar'), findsNothing);
  });
}
