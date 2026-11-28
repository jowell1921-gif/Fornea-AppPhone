import 'package:intl/intl.dart';

final NumberFormat _euro = NumberFormat.currency(
  locale: 'es_ES',
  symbol: '€',
  decimalDigits: 2,
);

/// Formatea para mostrar un importe recibido de la API como cadena decimal: `"9.50"` → `9,50 €`.
///
/// Equivale a `formatEuro` de la web. Es solo presentación: la app nunca suma ni calcula
/// importes definitivos, los decide el servidor. Por eso recibe la cadena tal cual llega.
String formatEuro(String amount) {
  final value = num.tryParse(amount);
  if (value == null || !value.isFinite) {
    throw FormatException('Importe no válido', amount);
  }
  return _euro.format(value);
}
