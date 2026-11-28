import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/dev/sample_account_source.dart';
import 'package:fornea/features/orders/presentation/orders_screen.dart';
import 'package:fornea/features/orders/presentation/widgets/order_tile.dart';
import 'package:fornea/features/profile/data/account_source.dart';
import 'package:fornea/features/profile/presentation/profile_screen.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  AccountSource? source,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (source != null) accountSourceProvider.overrideWithValue(source),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('sin sesión (como la app publicada hasta la Fase 5)', () {
    testWidgets('Perfil invita a iniciar sesión y no muestra datos', (
      tester,
    ) async {
      await _pump(tester, const ProfileScreen());

      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.textContaining('DATOS DE EJEMPLO'), findsNothing);
      // El club y las licencias siguen accesibles.
      expect(find.text('FORNEA CLUB'), findsOneWidget);
    });

    testWidgets('Pedidos invita a iniciar sesión', (tester) async {
      await _pump(tester, const OrdersScreen());

      expect(find.text('Inicia sesión'), findsOneWidget);
      expect(find.byType(OrderTile), findsNothing);
    });
  });

  group('con datos de ejemplo (solo desarrollo)', () {
    testWidgets(
      'Perfil avisa de que son de ejemplo y muestra puntos y pedidos',
      (tester) async {
        await _pump(
          tester,
          const ProfileScreen(),
          source: const SampleAccountSource(),
        );

        expect(find.textContaining('DATOS DE EJEMPLO'), findsOneWidget);
        expect(find.text('HOLA, EJEMPLO'), findsOneWidget);
        expect(find.text('180'), findsOneWidget);
        expect(
          find.text('Te faltan 70 puntos para «Recompensa de ejemplo».'),
          findsOneWidget,
        );
        expect(find.text('+31'), findsOneWidget);
        // Solo los tres más recientes.
        expect(find.byType(OrderTile, skipOffstage: false), findsNWidgets(3));
      },
    );

    testWidgets('Pedidos lista el historial con estados y modalidad', (
      tester,
    ) async {
      await _pump(
        tester,
        const OrdersScreen(),
        source: const SampleAccountSource(),
      );

      expect(find.textContaining('DATOS DE EJEMPLO'), findsOneWidget);
      expect(find.byType(OrderTile), findsNWidgets(4));
      expect(find.text('En preparación'), findsOneWidget);
      expect(find.text(' · A domicilio', findRichText: true), findsNothing);
      expect(
        find.textContaining('Pedido nº 1042', findRichText: true),
        findsOneWidget,
      );
    });
  });
}
