import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/app.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/fake_api.dart';

/// Arranca la app completa, igual que `main.dart`, pero sin red real.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [dioProvider.overrideWithValue(fakeDio(FakeHttpAdapter({})))],
      child: const ForneaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la app arranca en Inicio con la cabecera de marca', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('PIZZERÍA · RECOGIDA Y DOMICILIO'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('la barra inferior cambia de pestaña', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Carrito'));
    await tester.pumpAndSettle();
    expect(find.text('Tu carrito está vacío'), findsOneWidget);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Tu cuenta'), findsOneWidget);

    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('PIZZERÍA · RECOGIDA Y DOMICILIO'), findsOneWidget);
  });
}
