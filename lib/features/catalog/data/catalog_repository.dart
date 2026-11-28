import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/config/app_config.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/core/network/json_parsing.dart';
import 'package:fornea/features/catalog/domain/category.dart';
import 'package:fornea/features/catalog/domain/product.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(
    ref.watch(apiClientProvider),
    webBaseUrl: AppConfig.webBaseUrl,
  ),
);

/// Acceso a la carta pública (no necesita sesión). Es la única pieza que conoce las rutas de la
/// API del catálogo; la interfaz solo recibe modelos.
class CatalogRepository {
  const CatalogRepository(this._api, {required this._webBaseUrl});

  final ApiClient _api;
  final String _webBaseUrl;

  /// Categorías activas, en el orden de la carta.
  Future<List<Category>> fetchCategories() async =>
      parseList(await _api.get('/categories'), Category.fromJson);

  /// Todos los productos visibles (también los agotados), ordenados por categoría.
  ///
  /// Se pide la carta entera de una vez: es pequeña y así cambiar de categoría no hace
  /// más peticiones.
  Future<List<Product>> fetchProducts() async => parseList(
    await _api.get('/products'),
    (json) => Product.fromJson(json, resolveUrl: _resolveImageUrl),
  );

  /// Las imágenes que empiezan por `/` son relativas a la web; las demás ya son absolutas.
  String _resolveImageUrl(String url) =>
      url.startsWith('/') ? '$_webBaseUrl$url' : url;
}
