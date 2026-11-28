import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/loyalty/presentation/club_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_api.dart';

/// Respuesta real de `GET /loyalty/program` (copiada del backend local), con un campo nuevo
/// que la app debe ignorar.
final Map<String, Object?> _program = {
  'data': {
    'pointsPerEuro': '1',
    'expiryDays': null,
    'rewards': [
      {
        'id': 'r1',
        'name': 'Bebida gratis',
        'description': null,
        'pointsCost': 100,
        'benefit': {
          'type': 'FREE_PRODUCT',
          'productId': 'p1',
          'productName': 'Agua mineral',
          'amount': null,
        },
        'inStock': true,
      },
      {
        'id': 'r2',
        'name': '5 € de descuento',
        'description': 'En tu próximo pedido.',
        'pointsCost': 500,
        'benefit': {
          'type': 'DISCOUNT',
          'productId': null,
          'productName': null,
          'amount': '5.00',
        },
        'inStock': false,
        'campoNuevo': true,
      },
    ],
  },
};

Future<void> _pumpClub(WidgetTester tester, FakeHttpAdapter adapter) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [dioProvider.overrideWithValue(fakeDio(adapter))],
      child: const MaterialApp(home: ClubScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra la regla y las recompensas reales del programa', (
    tester,
  ) async {
    await _pumpClub(
      tester,
      FakeHttpAdapter({'/loyalty/program': (status: 200, body: _program)}),
    );

    expect(find.textContaining('sumas 1 punto (configurable'), findsOneWidget);
    expect(find.text('Bebida gratis'), findsOneWidget);
    expect(find.text('100 puntos'), findsOneWidget);
    expect(find.text('Producto gratis: Agua mineral'), findsOneWidget);
    expect(
      find.text('Descuento de 5,00 €', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Agotada de momento', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('sin conexión mantiene la página y permite reintentar', (
    tester,
  ) async {
    final adapter = FakeHttpAdapter({});
    await _pumpClub(tester, adapter);

    // El resto de la página (cómo funciona, preguntas) no depende de la API.
    expect(find.text('1. Pide'), findsOneWidget);
    expect(find.textContaining('No hemos podido conectar'), findsOneWidget);

    adapter.routes['/loyalty/program'] = (status: 200, body: _program);
    await tester.ensureVisible(find.text('Reintentar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Bebida gratis', skipOffstage: false), findsOneWidget);
  });
}
