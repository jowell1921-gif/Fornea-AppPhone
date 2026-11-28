/// Errores al hablar con la API, ya traducidos a casos que la interfaz sabe tratar.
///
/// `sealed` obliga a que un `switch` cubra todos los casos: si mañana añadimos uno, el analizador
/// señalará cada sitio que no lo trate.
sealed class ApiException implements Exception {
  const ApiException();
}

/// No hubo respuesta: sin conexión, servidor apagado o tiempo de espera agotado.
final class NetworkException extends ApiException {
  const NetworkException();

  @override
  String toString() => 'NetworkException';
}

/// El servidor respondió con un error en el formato de la API:
/// `{ "error": { "code", "message", "requestId" } }`.
///
/// La app decide por [code] (catálogo en `Pizzeria FORNO/docs/flutter/errores.md`). El `message`
/// del servidor es técnico y en inglés: nunca se muestra al cliente.
final class ServerException extends ApiException {
  const ServerException({
    required this.statusCode,
    required this.code,
    this.requestId,
  });

  final int statusCode;
  final String code;

  /// Identificador que el cliente puede comunicar si reclama.
  final String? requestId;

  @override
  String toString() =>
      'ServerException($statusCode, $code, requestId: $requestId)';
}

/// La respuesta no tiene la forma que dice el contrato. Indica un error de programación o un
/// cambio de la API, no un problema del cliente.
final class UnexpectedResponseException extends ApiException {
  const UnexpectedResponseException(this.detail);

  final String detail;

  @override
  String toString() => 'UnexpectedResponseException($detail)';
}
