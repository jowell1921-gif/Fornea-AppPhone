import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/formatting/money.dart';

void main() {
  // Espacio que no se parte de línea (U+00A0) entre la cifra y el símbolo, como en la web.
  const nbsp = ' ';

  test('formatea importes de la API como en la web', () {
    expect(formatEuro('9.50'), '9,50$nbsp€');
    expect(formatEuro('12'), '12,00$nbsp€');
    expect(formatEuro('0.5'), '0,50$nbsp€');
    expect(formatEuro('-2.00'), '-2,00$nbsp€');
  });

  test('separa los miles solo a partir de 5 cifras (formato es-ES)', () {
    expect(formatEuro('1234.50'), '1234,50$nbsp€');
    expect(formatEuro('12345.00'), '12.345,00$nbsp€');
    expect(formatEuro('1234567.89'), '1.234.567,89$nbsp€');
  });

  test('rechaza importes que no tienen el formato de la API', () {
    for (final invalid in ['abc', '', '9,50', '9.505', '1e3']) {
      expect(() => formatEuro(invalid), throwsFormatException, reason: invalid);
    }
  });
}
