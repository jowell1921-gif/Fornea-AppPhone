/// Escala de espaciados (múltiplos de 4) para márgenes, rellenos y separaciones.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Radios de las esquinas, equivalentes a los de la web (`--radius: 0.75rem` = 12).
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

/// Altura mínima de los elementos pulsables, recomendada por Android e iOS para el uso táctil.
const double kMinTouchTarget = 48;
