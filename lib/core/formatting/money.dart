/// Importe tal como lo envía la API: texto con dos decimales e IVA incluido (`"9.50"`, `"-2.00"`).
final RegExp _amountPattern = RegExp(r'^(-?)(\d+)(?:\.(\d{1,2}))?$');

/// Formatea para mostrar un importe de la API: `"9.50"` → `9,50 €`, igual que `formatEuro` de la web.
///
/// Trabaja sobre el texto, sin convertirlo a `double`, como pide la guía de la API: los `double`
/// no representan exactamente los céntimos. Es solo presentación; la app nunca calcula importes.
///
/// Sigue el formato español de la web: separador de miles solo a partir de 5 cifras
/// (`1234,50 €`, `12.345,00 €`) y un espacio que no se parte de línea antes de `€`.
String formatEuro(String amount) {
  final match = _amountPattern.firstMatch(amount.trim());
  if (match == null) throw FormatException('Importe no válido', amount);

  final sign = match.group(1)!;
  final integer = match.group(2)!.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  final cents = (match.group(3) ?? '').padRight(2, '0');

  return '$sign${_groupThousands(integer)},$cents €';
}

String _groupThousands(String digits) {
  if (digits.length < 5) return digits;
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Suplemento de una opción para mostrar junto a su nombre: `"1.50"` → `+1,50 €`,
/// `"-1.00"` → `-1,00 €`. Devuelve `null` si es cero (la web tampoco lo muestra).
///
/// Solo da formato al valor de la API; no suma nada.
String? formatPriceDelta(String delta) {
  final formatted = formatEuro(delta);
  if (RegExp(r'^-?0+(\.0+)?$').hasMatch(delta.trim())) return null;
  return formatted.startsWith('-') ? formatted : '+$formatted';
}
