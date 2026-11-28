import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/motion/motion.dart';
import 'package:fornea/core/motion/scroll_reveal.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/reduce_motion.dart';

Widget _floating() => Center(
  child: LoopingMotion(
    period: const Duration(seconds: 6),
    builder: (t, child) =>
        Transform.translate(offset: Offset(0, -10 + 20 * t), child: child),
    child: const SizedBox(key: Key('pizza'), width: 10, height: 10),
  ),
);

double _dy(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(const Key('pizza'))).dy;

void main() {
  testWidgets('la flotación mueve el contenido sin parar', (tester) async {
    await tester.pumpWidget(MaterialApp(home: _floating()));
    final start = _dy(tester);

    await tester.pump(const Duration(milliseconds: 1500));
    final middle = _dy(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    final end = _dy(tester);

    // A mitad de la ida ha bajado; al final de la ida (3 s), 20 px por debajo del inicio.
    expect(middle, greaterThan(start));
    expect(end - start, closeTo(20, 0.5));
    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('con «Quitar animaciones» no se mueve ni consume fotogramas', (
    tester,
  ) async {
    reduceMotion(tester);
    await tester.pumpWidget(MaterialApp(home: _floating()));
    final start = _dy(tester);

    await tester.pump(const Duration(seconds: 2));

    expect(_dy(tester), start);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('la aparición al desplazar muestra lo que entra en pantalla', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ListView(
          children: [
            // Justo debajo de la pantalla (600 de alto): la lista ya la construye.
            const SizedBox(height: 700),
            ScrollReveal(child: Container(key: const Key('card'), height: 200)),
            const SizedBox(height: 1000),
          ],
        ),
      ),
    );
    await tester.pump();

    double opacity() => tester
        .widget<Opacity>(
          find.ancestor(
            of: find.byKey(const Key('card'), skipOffstage: false),
            matching: find.byType(Opacity, skipOffstage: false),
          ),
        )
        .opacity;

    // Fuera de la pantalla (que mide 600 de alto): oculta.
    expect(opacity(), 0);

    // Desplazar hasta que entre del todo: visible.
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    // Un fotograma para medir y otro para dibujar con el nuevo valor.
    await tester.pump();
    expect(opacity(), 1);
  });
}
