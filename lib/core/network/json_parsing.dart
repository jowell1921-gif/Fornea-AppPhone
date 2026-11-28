import 'package:fornea/core/network/api_exception.dart';

/// Utilidades para convertir el JSON de la API en modelos sin usar `dynamic` ni `as` a ciegas.
/// Si algo no tiene la forma esperada, lanzan [UnexpectedResponseException].

/// Convierte una lista JSON aplicando [parse] a cada elemento.
List<T> parseList<T>(Object? json, T Function(Object? item) parse) =>
    switch (json) {
      final List<Object?> items => [for (final item in items) parse(item)],
      _ => throw const UnexpectedResponseException('Se esperaba una lista'),
    };

/// Lista de textos, como los ingredientes.
List<String> parseStringList(Object? json) => parseList(
  json,
  (item) => switch (item) {
    final String value => value,
    _ => throw const UnexpectedResponseException('Se esperaba un texto'),
  },
);
