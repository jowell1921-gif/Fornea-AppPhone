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
