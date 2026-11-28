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
