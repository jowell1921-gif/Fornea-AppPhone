import 'package:fornea/core/network/api_exception.dart';

/// Categoría de la carta (`GET /categories`). Llegan ya ordenadas y solo las activas.
class Category {
  const Category({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
  });

  /// Lee el JSON de la API. El *pattern* de mapa comprueba a la vez que cada campo exista y tenga
  /// el tipo correcto; los campos que la app no conoce se ignoran (la API puede añadir más).
  factory Category.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'slug': final String slug,
      'name': final String name,
      'description': final String? description,
    } =>
      Category(id: id, slug: slug, name: name, description: description),
    _ => throw const UnexpectedResponseException('Categoría no válida'),
  };

  final String id;

  /// Identificador legible (`pizzas`); se usa para filtrar productos.
  final String slug;
  final String name;
  final String? description;
}
