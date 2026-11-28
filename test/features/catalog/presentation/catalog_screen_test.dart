import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/catalog/presentation/catalog_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_api.dart';
import '../../../helpers/reduce_motion.dart';

Future<void> _pumpCatalog(WidgetTester tester, FakeHttpAdapter adapter) async {
  reduceMotion(tester);
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
        for (var i = 1; i <= 6; i++)
          productJson(id: 'p$i', categoryId: 'c1', name: 'Pizza $i'),
        productJson(
          id: 'b1',
          categoryId: 'c2',
          name: 'Agua',
          overrides: {'available': false},
        ),
      ],
    },
  ),
};

/// Las secciones fuera de pantalla existen pero no se «ven»: se buscan sin ese filtro.
Finder _anywhere(String text) => find.text(text, skipOffstage: false);

void main() {
  testWidgets('muestra los productos agrupados por categoría', (tester) async {
    await _pumpCatalog(tester, FakeHttpAdapter({..._menu}));

    expect(find.text('NUESTRA CARTA'), findsOneWidget);
    expect(_anywhere('PIZZAS'), findsOneWidget);
    expect(_anywhere('Pizza 1'), findsOneWidget);
    expect(_anywhere('BEBIDAS'), findsOneWidget);
    expect(_anywhere('No disponible'), findsOneWidget);
    // Una categoría sin productos no tiene sección ni botón en la barra.
    expect(_anywhere('POSTRES'), findsNothing);
    expect(_anywhere('Postres'), findsNothing);
  });

  testWidgets('pulsar una categoría de la barra lleva a su sección', (
    tester,
  ) async {
    await _pumpCatalog(tester, FakeHttpAdapter({..._menu}));
    expect(find.text('BEBIDAS'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Bebidas'));
    await tester.pumpAndSettle();

    expect(find.text('BEBIDAS'), findsOneWidget);
    // La barra sigue fija arriba.
    expect(find.widgetWithText(OutlinedButton, 'Pizzas'), findsOneWidget);
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

    expect(find.text('NUESTRA CARTA'), findsOneWidget);
  });

  testWidgets('si falla una recarga se mantiene la carta y se avisa', (
    tester,
  ) async {
    final adapter = FakeHttpAdapter({..._menu});
    await _pumpCatalog(tester, adapter);

    adapter.routes.clear();
    await tester.fling(find.text('NUESTRA CARTA'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.textContaining('No hemos podido conectar'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('NUESTRA CARTA'), findsOneWidget);
  });
}
