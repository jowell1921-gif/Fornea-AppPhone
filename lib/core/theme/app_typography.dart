import 'package:material_ui/material_ui.dart';

/// Familias tipográficas registradas en `pubspec.yaml` (archivos en `assets/fonts/`).
abstract final class AppFonts {
  /// Textos e interfaz.
  static const String body = 'Inter';

  /// Títulos, como en la web: Barlow Condensed ExtraBold.
  static const String heading = 'BarlowCondensed';
}

/// Estilos de texto de la app sobre la escala tipográfica de Material 3.
abstract final class AppTypography {
  /// Aplica Barlow Condensed a los títulos grandes y deja Inter (la fuente por defecto del tema)
  /// en el resto. Los tamaños son los de Material 3, que ya están pensados para móvil.
  static TextTheme textTheme(TextTheme base) {
    TextStyle? heading(TextStyle? style, FontWeight weight) =>
        style?.copyWith(fontFamily: AppFonts.heading, fontWeight: weight);

    return base.copyWith(
      displayLarge: heading(base.displayLarge, FontWeight.w800),
      displayMedium: heading(base.displayMedium, FontWeight.w800),
      displaySmall: heading(base.displaySmall, FontWeight.w800),
      headlineLarge: heading(base.headlineLarge, FontWeight.w800),
      headlineMedium: heading(base.headlineMedium, FontWeight.w800),
      headlineSmall: heading(base.headlineSmall, FontWeight.w700),
      titleLarge: heading(base.titleLarge, FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      // Material 3 separa las letras del texto de cuerpo (0,25–0,5); con Inter queda demasiado
      // abierto y la web usa espaciado normal.
      bodyLarge: base.bodyLarge?.copyWith(letterSpacing: 0),
      bodyMedium: base.bodyMedium?.copyWith(letterSpacing: 0),
      bodySmall: base.bodySmall?.copyWith(letterSpacing: 0),
    );
  }
}
