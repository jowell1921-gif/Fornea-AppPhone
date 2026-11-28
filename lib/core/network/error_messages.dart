import 'package:fornea/core/network/api_exception.dart';

/// Texto para el cliente a partir de un error de carga. Nunca muestra detalles internos.
///
/// Los códigos de negocio concretos (pedido mínimo, local cerrado…) tendrán sus propios textos
/// en la funcionalidad que los provoque; esto cubre los errores generales de carga.
String loadErrorMessage(Object error) => switch (error) {
  NetworkException() => 'No hemos podido conectar con FORNEA. Revisa tu conexión e inténtalo de nuevo.',
  ServerException(statusCode: 429) => 'Hay demasiadas peticiones ahora mismo. Espera unos segundos e inténtalo de nuevo.',
  ServerException(statusCode: >= 500) => 'El servicio no está disponible en este momento. Inténtalo de nuevo en unos minutos.',
  _ => 'Ha ocurrido un error inesperado. Inténtalo de nuevo.',
};

/// Texto para los errores al presupuestar un producto o el carrito (`POST /checkout/quote`).
/// Los códigos son los de `docs/flutter/errores.md` del backend.
String quoteErrorMessage(Object error) => switch (error) {
  ServerException(code: 'PRODUCT_UNAVAILABLE') =>
    'Este producto se ha agotado.',
  ServerException(code: 'PRODUCT_NOT_FOUND') =>
    'Este producto ya no está en la carta.',
  ServerException(code: 'OPTION_UNAVAILABLE') =>
    'Una de las opciones elegidas se ha agotado. Elige otra.',
  ServerException(code: 'INVALID_OPTIONS') => 'Revisa las opciones elegidas.',
  _ => loadErrorMessage(error),
};

/// Errores del presupuesto que se deben a la selección o al producto (no a la red):
/// mientras ocurran no se puede añadir al pedido.
bool isRejectedSelection(Object error) => switch (error) {
  ServerException(statusCode: 422) => true,
  _ => false,
};
