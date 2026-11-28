import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/catalog/presentation/product_detail/product_detail_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/fake_api.dart';

Map<String, Object?> _pizza({bool available = true}) => productJson(
  id: 'p1',
  categoryId: 'c1',
  overrides: {
    'available': available,
    'optionGroups': [
      optionGroupJson(
        id: 'size',
        name: 'Tamaño',
        required: true,
        minSelect: 1,
        options: [
          optionJson(id: 'm', name: 'Mediana', isDefault: true),
          optionJson(id: 'f', name: 'Familiar', priceDelta: '4.00'),
        ],
      ),
    ],
  },
);

Future<FakeHttpAdapter> _pumpDetail(
  WidgetTester tester, {
  Map<String, Object?>? product,
  FakeResponse? quote,
}) async {
  // Tamaño de un móvil real (1080×2400), para que la ficha entera quepa en pantalla.
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  final adapter = FakeHttpAdapter({
    '/products/p1': (status: 200, body: {'data': product ?? _pizza()}),
    '/checkout/quote': ?quote,
  });
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [dioProvider.overrideWithValue(fakeDio(adapter))],
      child: const MaterialApp(home: ProductDetailScreen(productId: 'p1')),
    ),
  );
  await tester.pumpAndSettle();
  // Espera la pausa antes de pedir el precio y su respuesta.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
  return adapter;
}

void main() {
  testWidgets('muestra la ficha y el precio calculado por el servidor', (
    tester,
  ) async {
    final adapter = await _pumpDetail(
      tester,
      quote: (
        status: 200,
        body: quoteJson(unitPrice: '9.50', lineTotal: '9.50'),
      ),
    );

    expect(find.text('MARGHERITA'), findsOneWidget);
    expect(find.text('Gluten'), findsOneWidget);
    expect(find.text('Familiar'), findsOneWidget);
    expect(find.text('+4,00 €'), findsOneWidget);
    expect(find.text('AÑADIR · 9,50 €'), findsOneWidget);
    expect(adapter.requests, contains('/checkout/quote'));
  });

  testWidgets('si el servidor rechaza la selección no deja añadir', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      quote: (
        status: 422,
        body: {
          'error': {'code': 'OPTION_UNAVAILABLE', 'message': 'x'},
        },
      ),
    );

    expect(find.textContaining('se ha agotado. Elige otra'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'AÑADIR'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('un producto agotado no muestra opciones ni pide precio', (
    tester,
  ) async {
    final adapter = await _pumpDetail(
      tester,
      product: _pizza(available: false),
    );

    expect(find.text('NO DISPONIBLE'), findsOneWidget);
    expect(find.text('Familiar'), findsNothing);
    expect(adapter.requests, isNot(contains('/checkout/quote')));
  });

  testWidgets('un producto que ya no existe lo dice y ofrece volver', (
    tester,
  ) async {
    final adapter = FakeHttpAdapter({
      '/products/p1': (
        status: 404,
        body: {
          'error': {'code': 'NOT_FOUND', 'message': 'x'},
        },
      ),
    });
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [dioProvider.overrideWithValue(fakeDio(adapter))],
        child: const MaterialApp(home: ProductDetailScreen(productId: 'p1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Este producto ya no está en la carta'), findsOneWidget);
  });
}
