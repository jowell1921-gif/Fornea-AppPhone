const List<String> _shortMonths = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sept',
  'oct',
  'nov',
  'dic',
];

/// Fecha corta en español, como la web: `28 nov 2026`.
///
/// La API envía las fechas en UTC (`2026-11-28T18:30:00.000Z`); se muestran en la hora local
/// del móvil. Es solo presentación; la app es solo en español, así que no hace falta el paquete
/// `intl` para esto.
String formatShortDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_shortMonths[local.month - 1]} ${local.year}';
}

/// Mes y año: `noviembre de 2026` («Cliente desde…»).
String formatMonthYear(DateTime date) {
  const months = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  final local = date.toLocal();
  return '${months[local.month - 1]} de ${local.year}';
}
