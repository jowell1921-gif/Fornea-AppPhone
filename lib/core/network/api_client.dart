import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/config/app_config.dart';
import 'package:fornea/core/network/api_exception.dart';

/// Cliente HTTP compartido. En las pruebas se sustituye con `overrideWithValue`.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);

/// Envuelve Dio con las convenciones de la API de FORNEA: respuestas `{ "data": … }` y errores
/// `{ "error": { "code", … } }`. Los repositorios solo reciben `data` o un [ApiException].
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  /// `GET` que devuelve el contenido de `data`, sin convertir: cada repositorio lo interpreta.
  Future<Object?> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query));

  /// `POST` con un cuerpo JSON; devuelve el contenido de `data` igual que [get].
  Future<Object?> post(String path, {Object? body}) =>
      _send(() => _dio.post<Object?>(path, data: body));

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      final response = await request();
      return switch (response.data) {
        {'data': final Object? data} => data,
        _ => throw const UnexpectedResponseException('Falta "data"'),
      };
    } on DioException catch (error) {
      throw _translate(error);
    }
  }

  static ApiException _translate(DioException error) {
    final response = error.response;
    if (response == null) return const NetworkException();

    return switch (response.data) {
      {
        'error': {'code': final String code} && final Map<String, Object?> body,
      } =>
        ServerException(
          statusCode: response.statusCode ?? 0,
          code: code,
          requestId: switch (body['requestId']) {
            final String id => id,
            _ => null,
          },
        ),
      // Respuestas sin el formato de la API (por ejemplo, un proxy caído devolviendo HTML).
      _ => ServerException(
        statusCode: response.statusCode ?? 0,
        code: 'UNKNOWN',
      ),
    };
  }
}
