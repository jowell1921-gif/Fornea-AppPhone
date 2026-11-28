import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/catalog/presentation/catalog_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_api.dart';

Future<void> _pumpCatalog(WidgetTester tester, FakeHttpAdapter adapter) async {
  await tester.pumpWidget(
    ProviderScope(
      // Sin reintentos automáticos: la prueba controla cuándo se reintenta.
      retry: (_, _) => null,
      overrides: [dioProvider.overrideWithValue(fakeDio(adapter))],
      child: const MaterialApp(home: CatalogScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

final Map<String, FakeResponse> _menu = {
  '/categories': (
    status: 200,
    body: {
      'data': [
        categoryJson(id: 'c1', name: 'Pizzas'),
        categoryJson(id: 'c2', name: 'Bebidas'),
        categoryJson(id: 'c3', name: 'Postres'),
      ],
    },
  ),
  '/products': (
    status: 200,
    body: {
      'data': [
        productJson(id: 'p1', categoryId: 'c1', name: 'Margherita'),
        productJson(
          id: 'p2',
          categoryId: 'c2',
          name: 'Agua',
          overrides: {'available': false},
        ),
      ],
    },
  ),
};

void main() {
  testWidgets('muestra los productos agrupados por categoría', (tester) async {
    await _pumpCatalog(tester, FakeHttpAdapter({..._menu}));

    expect(find.text('PIZZAS'), findsOneWidget);
    expect(find.text('Margherita'), findsOneWidget);
    expect(find.text('BEBIDAS'), findsOneWidget);
    expect(find.text('No disponible'), findsOneWidget);
    // Una categoría sin productos no se muestra.
    expect(find.text('POSTRES'), findsNothing);
  });

  testWidgets('sin conexión muestra el error y «Reintentar» vuelve a cargar', (
    tester,
  ) async {
    final adapter = FakeHttpAdapter({});
    await _pumpCatalog(tester, adapter);

    expect(find.textContaining('No hemos podido conectar'), findsOneWidget);

    adapter.routes.addAll(_menu);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Margherita'), findsOneWidget);
  });
}
