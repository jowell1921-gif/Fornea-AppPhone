import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/cart/data/cart_storage.dart';
import 'package:fornea/features/cart/presentation/cart_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/memory_cart_storage.dart';

Future<void> _pumpCart(
  WidgetTester tester, {
  required MemoryCartStorage storage,
  Map<String, FakeResponse> routes = const {},
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        cartStorageProvider.overrideWithValue(storage),
        dioProvider.overrideWithValue(fakeDio(FakeHttpAdapter({...routes}))),
      ],
      child: const MaterialApp(home: CartScreen()),
    ),
  );
  await tester.pumpAndSettle();
  // Espera la pausa antes de pedir el presupuesto y su respuesta.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('vacío: lo dice y ofrece ir a la carta', (tester) async {
    await _pumpCart(tester, storage: MemoryCartStorage());

    expect(find.text('Tu pedido está vacío'), findsOneWidget);
    expect(find.text('Ver la carta'), findsOneWidget);
  });

  testWidgets('muestra las líneas con los importes del servidor', (
    tester,
  ) async {
    await _pumpCart(
      tester,
      storage: MemoryCartStorage([
        cartLine('p1', options: ['a'], quantity: 2, notes: 'sin albahaca'),
        cartLine('p2'),
      ]),
      routes: {
        '/checkout/quote': (
          status: 200,
          body: quoteJson(
            lines: [
              quoteLineJson(
                productId: 'p1',
                optionIds: ['a'],
                quantity: 2,
                notes: 'sin albahaca',
                lineTotal: '27.00',
              ),
              quoteLineJson(productId: 'p2', lineTotal: '2.50'),
            ],
            discounts: [
              {'description': 'Promoción de bienvenida', 'amount': '2.00'},
            ],
            total: '27.50',
          ),
        ),
      },
    );

    expect(find.text('Producto p1'), findsOneWidget);
    expect(find.text('«sin albahaca»'), findsOneWidget);
    expect(find.text('27,00 €'), findsOneWidget);
    expect(find.text('Promoción de bienvenida'), findsOneWidget);
    expect(find.text('FINALIZAR PEDIDO · 27,50 €'), findsOneWidget);
  });

  testWidgets('si el servidor rechaza el carrito no deja finalizar', (
    tester,
  ) async {
    await _pumpCart(
      tester,
      storage: MemoryCartStorage([cartLine('p1')]),
      routes: {
        '/checkout/quote': (
          status: 422,
          body: {
            'error': {'code': 'PRODUCT_UNAVAILABLE', 'message': 'x'},
          },
        ),
      },
    );

    expect(find.textContaining('Este producto se ha agotado'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'FINALIZAR PEDIDO'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('quitar una línea se puede deshacer', (tester) async {
    final storage = MemoryCartStorage([cartLine('p1'), cartLine('p2')]);
    await _pumpCart(tester, storage: storage);

    await tester.tap(find.byTooltip('Quitar Producto p1 del pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Producto p1'), findsNothing);
    expect(storage.saved, hasLength(1));

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(find.text('Producto p1'), findsOneWidget);
    expect(storage.saved, hasLength(2));
  });
}
