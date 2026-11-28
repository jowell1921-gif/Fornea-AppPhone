import 'package:fornea/core/network/api_exception.dart';

/// Política de reintentos automáticos de Riverpod para los providers que cargan datos.
///
/// Sigue la guía de la API: ante fallos de red o errores `5xx`, reintentar con espera creciente
/// (0,5 s, 1 s, 2 s) y un máximo de 3 veces. Los demás errores no se arreglan reintentando igual,
/// así que se muestran enseguida. Se aplica a toda la app desde `ProviderScope` en `main.dart`.
Duration? apiRetryPolicy(int retryCount, Object error) {
  if (retryCount >= 3) return null;

  final retryable = switch (error) {
    NetworkException() => true,
    ServerException(statusCode: >= 500) => true,
    _ => false,
  };
  return retryable ? Duration(milliseconds: 500 * (1 << retryCount)) : null;
}
