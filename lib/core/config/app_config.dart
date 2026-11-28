import 'package:flutter/foundation.dart';

/// Direcciones del servidor según el entorno, leídas de variables de compilación.
///
/// Se indican al compilar con `--dart-define=API_BASE_URL=...` (o `--dart-define-from-file`).
/// En debug, si no se indican, se usa el servidor local visto desde el emulador de Android
/// (`10.0.2.2` es el «localhost» del PC). En la versión publicada son obligatorias: es preferible
/// que la app no arranque a que apunte por error a un PC de desarrollo.
///
/// No son secretos (cualquiera puede ver a qué servidor llama una app); las claves privadas
/// nunca van en la app.
abstract final class AppConfig {
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _webBaseUrl = String.fromEnvironment('WEB_BASE_URL');

  static const String _localApiBaseUrl = 'http://10.0.2.2:4000/api/v1';
  static const String _localWebBaseUrl = 'http://10.0.2.2:3000';

  /// Base de la API REST, por ejemplo `https://api.forneapizzeria.es/api/v1`.
  static String get apiBaseUrl =>
      _resolve(_apiBaseUrl, _localApiBaseUrl, 'API_BASE_URL');

  /// Base de la web. Las imágenes de la carta llegan como rutas relativas a ella (`/image/…`).
  static String get webBaseUrl =>
      _resolve(_webBaseUrl, _localWebBaseUrl, 'WEB_BASE_URL');

  static String _resolve(String value, String localDefault, String name) {
    if (value.isNotEmpty) return value;
    if (kReleaseMode) {
      throw StateError('Falta --dart-define=$name en la compilación.');
    }
    return localDefault;
  }
}
