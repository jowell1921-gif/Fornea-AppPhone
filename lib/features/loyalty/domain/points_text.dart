/// Textos de puntos en español. Solo dan formato a lo que dice el servidor; no calculan nada.
library;

/// `1 punto`, `250 puntos`.
String pointsText(int points) =>
    '$points ${points.abs() == 1 ? 'punto' : 'puntos'}';

/// Regla del programa en palabras, como la web: `"1"` → `1 punto por cada euro`,
/// `"0.5"` → `0,5 puntos por cada euro`.
String pointsRuleText(String? pointsPerEuro) {
  if (pointsPerEuro == null) return 'puntos por cada euro de tus pedidos';

  // Se quitan los ceros sobrantes («1.00» → «1») y se usa la coma decimal.
  var value = pointsPerEuro.trim();
  if (value.contains('.')) {
    value = value
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  final unit = value == '1' ? 'punto' : 'puntos';
  return '${value.replaceFirst('.', ',')} $unit por cada euro';
}
