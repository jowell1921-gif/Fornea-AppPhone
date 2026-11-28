import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/features/catalog/presentation/widgets/product_card.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('muestra nombre, precio «desde», ingredientes y etiquetas', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ProductCard(
          name: 'Pizza',
          description: 'Descripción',
          price: '9.50',
          ingredients: const ['Tomate', 'Mozzarella'],
          allergens: const ['Gluten'],
          vegetarian: true,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Pizza'), findsOneWidget);
    expect(find.text('desde 9,50 €'), findsOneWidget);
    expect(find.text('Ingredientes: Tomate, Mozzarella'), findsOneWidget);
    expect(find.text('Alérgenos: Gluten'), findsOneWidget);
    expect(find.text('Vegetariano'), findsOneWidget);
    expect(find.text('No disponible'), findsNothing);
  });

  testWidgets('marca el producto no disponible y responde al toque', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        ProductCard(
          name: 'Pizza',
          description: 'Descripción',
          price: '12',
          available: false,
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.text('No disponible'), findsOneWidget);
    await tester.tap(find.text('Pizza'));
    expect(taps, 1);
  });
}
