import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/empty_state.dart';
import 'package:fornea/core/widgets/error_view.dart';
import 'package:fornea/core/widgets/loading_view.dart';
import 'package:fornea/features/catalog/domain/category.dart';
import 'package:fornea/features/catalog/domain/product.dart';
import 'package:fornea/features/catalog/presentation/catalog_providers.dart';
import 'package:fornea/features/catalog/presentation/widgets/product_card.dart';
import 'package:material_ui/material_ui.dart';

/// Carta: productos reales del backend agrupados por categoría.
///
/// Versión funcional de la tarea 4.1; el diseño definitivo (selector de categorías, detalle)
/// llega en las tareas 4.3 y 4.4.
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);

    // Se combinan las dos cargas: hasta que ambas terminan se muestra un único estado.
    final Widget body = switch ((categories, products)) {
      (AsyncData(value: final cats), AsyncData(value: final prods)) =>
        _CatalogList(categories: cats, products: prods),
      (AsyncError(:final error), _) ||
      (_, AsyncError(:final error)) => ErrorView(
        message: loadErrorMessage(error),
        onRetry: () {
          ref
            ..invalidate(categoriesProvider)
            ..invalidate(productsProvider);
        },
      ),
      _ => const LoadingView(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Carta')),
      body: body,
    );
  }
}

class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.categories, required this.products});

  final List<Category> categories;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sections = [
      for (final category in categories)
        (category, products.where((p) => p.categoryId == category.id).toList()),
    ].where((section) => section.$2.isNotEmpty).toList();

    if (sections.isEmpty) {
      return const EmptyState(
        icon: Icons.restaurant_menu,
        title: 'La carta está vacía',
        message: 'Vuelve en un rato: estamos preparando los productos.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final (category, items) in sections) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              category.name.toUpperCase(),
              style: textTheme.headlineSmall,
            ),
          ),
          for (final product in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ProductCard(
                name: product.name,
                description: product.description,
                price: product.price,
                imageUrl: product.image?.url,
                imageAlt: product.image?.alt ?? '',
                ingredients: product.ingredients,
                allergens: [for (final a in product.allergens) a.name],
                vegetarian: product.vegetarian,
                available: product.available,
                // El detalle del producto llega en la tarea 4.4.
                onTap: () {},
              ),
            ),
        ],
      ],
    );
  }
}
