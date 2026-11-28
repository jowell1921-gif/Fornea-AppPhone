import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/formatting/dates.dart';
import 'package:fornea/features/loyalty/domain/points_text.dart';

void main() {
  test('puntos en singular y plural', () {
    expect(pointsText(1), '1 punto');
    expect(pointsText(-1), '-1 punto');
    expect(pointsText(250), '250 puntos');
  });

  test('regla del programa como en la web', () {
    expect(pointsRuleText('1'), '1 punto por cada euro');
    expect(pointsRuleText('1.00'), '1 punto por cada euro');
    expect(pointsRuleText('0.5'), '0,5 puntos por cada euro');
    expect(pointsRuleText('2'), '2 puntos por cada euro');
    expect(pointsRuleText(null), 'puntos por cada euro de tus pedidos');
  });

  test('fechas cortas en español', () {
    // A mediodía UTC, para que la zona horaria del equipo no cambie el día.
    final date = DateTime.utc(2026, 11, 28, 12);
    expect(formatShortDate(date), '28 nov 2026');
    expect(formatMonthYear(date), 'noviembre de 2026');
  });
}
