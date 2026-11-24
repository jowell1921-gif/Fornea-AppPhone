import 'package:material_ui/material_ui.dart';

/// Paleta de marca de FORNEA, idéntica a los tokens de la web (`frontend/src/app/globals.css`).
///
/// El tomate de marca ([tomato]) no alcanza el contraste AA con texto blanco (4,22:1), así que
/// la web y la app usan variantes más oscuras para botones y texto pequeño (decisión 0002 de la web):
/// - [tomatoStrong] para botones y texto pequeño sobre blanco (5,30:1).
/// - [tomatoDeep] para texto pequeño sobre crema.
/// - [gold] solo sobre [charcoal]: sobre blanco no se lee (2,2:1).
abstract final class AppColors {
  static const Color tomato = Color(0xFFD94A32);
  static const Color tomatoStrong = Color(0xFFBF3F2A);
  static const Color tomatoDeep = Color(0xFFA53320);
  static const Color charcoal = Color(0xFF171717);
  static const Color cream = Color(0xFFF5E6C8);
  static const Color creamSoft = Color(0xFFFBF5E8);
  static const Color gold = Color(0xFFD6A84B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color inkMuted = Color(0xFF5C5148);
  static const Color border = Color(0xFFE6D9BD);
  static const Color input = Color(0xFFCBBD9F);
  static const Color error = Color(0xFFB42318);
}
