import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/formatting/money.dart';

void main() {
  // intl separa la cifra y el símbolo con un espacio que no se parte de línea (U+00A0).
  const nbsp = ' ';

  test('formatea importes de la API como en la web', () {
    expect(formatEuro('9.50'), '9,50$nbsp€');
    expect(formatEuro('12'), '12,00$nbsp€');
    expect(formatEuro('0.5'), '0,50$nbsp€');
  });

  test('rechaza importes que no son números', () {
    expect(() => formatEuro('abc'), throwsFormatException);
    expect(() => formatEuro(''), throwsFormatException);
  });
}
