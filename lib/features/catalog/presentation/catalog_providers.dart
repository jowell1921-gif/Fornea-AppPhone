import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/features/catalog/data/catalog_repository.dart';
import 'package:fornea/features/catalog/domain/category.dart';
import 'package:fornea/features/catalog/domain/product.dart';

/// Estado de la carta para la interfaz. Un `FutureProvider` ejecuta la carga una vez, guarda el
/// resultado y lo comparte con todas las pantallas que lo lean (Inicio y Carta).
/// La interfaz lo recibe como `AsyncValue`: cargando, error o datos.

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(catalogRepositoryProvider).fetchCategories(),
);

final productsProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(catalogRepositoryProvider).fetchProducts(),
);

/// Un producto para su ficha.
///
/// Si la carta ya está cargada se toma de ahí (sin otra petición); si no (por ejemplo, al abrir
/// un enlace directo), se pide a la API. `family` crea un provider por cada id y `autoDispose`
/// lo libera al cerrar la ficha.
final productProvider = FutureProvider.autoDispose.family<Product, String>((
  ref,
  id,
) async {
  final cached = ref.read(productsProvider).value;
  for (final product in cached ?? const <Product>[]) {
    if (product.id == id) return product;
  }
  return ref.watch(catalogRepositoryProvider).fetchProduct(id);
});

/// «Nuestros favoritos» de Inicio: los destacados que se pueden pedir, como máximo 4
/// (mismo criterio que la web). Se deriva de [productsProvider], así que no hace otra petición.
final favouriteProductsProvider = Provider<AsyncValue<List<Product>>>(
  (ref) => ref
      .watch(productsProvider)
      .whenData(
        (products) =>
            products.where((p) => p.popular && p.available).take(4).toList(),
      ),
);
