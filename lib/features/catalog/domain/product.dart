import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/core/network/json_parsing.dart';

/// Convierte la URL de una imagen tal como llega de la API en una URL absoluta.
typedef UrlResolver = String Function(String url);

/// Producto de la carta (`GET /products`), según el esquema `Product` del contrato OpenAPI.
///
/// Los importes se guardan como texto (`"9.50"`): la app solo los muestra, nunca los calcula.
class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.categoryId,
    required this.categorySlug,
    required this.name,
    required this.description,
    required this.price,
    required this.vegetarian,
    required this.available,
    required this.popular,
    required this.image,
    required this.ingredients,
    required this.allergens,
    required this.optionGroups,
  });

  factory Product.fromJson(Object? json, {required UrlResolver resolveUrl}) =>
      switch (json) {
        {
          'id': final String id,
          'slug': final String slug,
          'categoryId': final String categoryId,
          'categorySlug': final String categorySlug,
          'name': final String name,
          'description': final String description,
          'price': final String price,
          'vegetarian': final bool vegetarian,
          'available': final bool available,
          'popular': final bool popular,
          'image': final Object? image,
          'ingredients': final Object? ingredients,
          'allergens': final Object? allergens,
          'optionGroups': final Object? optionGroups,
        } =>
          Product(
            id: id,
            slug: slug,
            categoryId: categoryId,
            categorySlug: categorySlug,
            name: name,
            description: description,
            price: price,
            vegetarian: vegetarian,
            available: available,
            popular: popular,
            image: image == null
                ? null
                : ProductPhoto.fromJson(image, resolveUrl: resolveUrl),
            ingredients: parseStringList(ingredients),
            allergens: parseList(allergens, Allergen.fromJson),
            optionGroups: parseList(optionGroups, OptionGroup.fromJson),
          ),
        _ => throw const UnexpectedResponseException('Producto no válido'),
      };

  final String id;
  final String slug;
  final String categoryId;
  final String categorySlug;
  final String name;
  final String description;

  /// Precio mínimo con IVA (el de las opciones por defecto); en la carta se muestra «desde».
  final String price;
  final bool vegetarian;

  /// `false` si está agotado: se muestra, pero no se puede pedir.
  final bool available;

  /// Destacado: aparece en «Las favoritas» de Inicio.
  final bool popular;

  /// Imagen principal, o `null` si el producto no tiene foto.
  final ProductPhoto? image;
  final List<String> ingredients;
  final List<Allergen> allergens;
  final List<OptionGroup> optionGroups;
}

class ProductPhoto {
  const ProductPhoto({required this.url, required this.alt});

  /// Si la URL empieza por `/` es relativa a la web (guía de la API); [resolveUrl] la completa.
  factory ProductPhoto.fromJson(
    Object? json, {
    required UrlResolver resolveUrl,
  }) => switch (json) {
    {'url': final String url, 'alt': final String alt} => ProductPhoto(
      url: resolveUrl(url),
      alt: alt,
    ),
    _ => throw const UnexpectedResponseException('Imagen no válida'),
  };

  final String url;

  /// Texto alternativo para lectores de pantalla (puede venir vacío).
  final String alt;
}

class Allergen {
  const Allergen({required this.code, required this.name});

  factory Allergen.fromJson(Object? json) => switch (json) {
    {'code': final String code, 'name': final String name} => Allergen(
      code: code,
      name: name,
    ),
    _ => throw const UnexpectedResponseException('Alérgeno no válido'),
  };

  final String code;
  final String name;
}

/// Tipo de grupo de opciones. La API puede añadir tipos nuevos sin cambiar de versión, así que
/// los desconocidos se leen como [unknown] en lugar de romper la carta.
enum OptionKind {
  size,
  dough,
  extraIngredient,
  extra,
  unknown;

  static OptionKind fromJson(String value) => switch (value) {
    'SIZE' => size,
    'DOUGH' => dough,
    'EXTRA_INGREDIENT' => extraIngredient,
    'EXTRA' => extra,
    _ => unknown,
  };
}

/// Grupo de opciones de un producto (tamaño, masa, ingredientes extra…).
/// Las reglas ([minSelect], [maxSelect]) las valida también el servidor al pedir.
class OptionGroup {
  const OptionGroup({
    required this.id,
    required this.name,
    required this.kind,
    required this.required,
    required this.minSelect,
    required this.maxSelect,
    required this.options,
  });

  factory OptionGroup.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'name': final String name,
      'kind': final String kind,
      'required': final bool required,
      'minSelect': final int minSelect,
      'maxSelect': final int maxSelect,
      'options': final Object? options,
    } =>
      OptionGroup(
        id: id,
        name: name,
        kind: OptionKind.fromJson(kind),
        required: required,
        minSelect: minSelect,
        maxSelect: maxSelect,
        options: parseList(options, ProductOption.fromJson),
      ),
    _ => throw const UnexpectedResponseException('Grupo de opciones no válido'),
  };

  final String id;
  final String name;
  final OptionKind kind;
  final bool required;
  final int minSelect;
  final int maxSelect;
  final List<ProductOption> options;
}

class ProductOption {
  const ProductOption({
    required this.id,
    required this.name,
    required this.priceDelta,
    required this.isDefault,
    required this.available,
  });

  factory ProductOption.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'name': final String name,
      'priceDelta': final String priceDelta,
      'isDefault': final bool isDefault,
      'available': final bool available,
    } =>
      ProductOption(
        id: id,
        name: name,
        priceDelta: priceDelta,
        isDefault: isDefault,
        available: available,
      ),
    _ => throw const UnexpectedResponseException('Opción no válida'),
  };

  final String id;
  final String name;

  /// Suplemento sobre el precio base (`"4.00"`); solo informativo, el total lo calcula el servidor.
  final String priceDelta;
  final bool isDefault;
  final bool available;
}
