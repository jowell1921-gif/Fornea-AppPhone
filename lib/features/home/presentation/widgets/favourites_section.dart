import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/section_heading.dart';
import 'package:fornea/features/catalog/presentation/catalog_providers.dart';
import 'package:fornea/features/catalog/presentation/widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// «Nuestros favoritos»: productos destacados reales del backend.
class FavouritesSection extends ConsumerWidget {
  const FavouritesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouriteProductsProvider);

    final Widget content = switch (favourites) {
      AsyncData(value: final products) when products.isEmpty => const Text(
        'Pronto destacaremos aquí nuestras recetas favoritas.',
      ),
      AsyncData(value: final products) => Column(
        children: [
          for (final product in products)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ProductCard.fromProduct(
                product,
                // Hasta tener el detalle (tarea 4.4) lleva a la carta.
                onTap: () => context.go(AppRoutes.catalog),
              ),
            ),
        ],
      ),
      AsyncError(:final error) => _InlineError(
        message: loadErrorMessage(error),
        onRetry: () => ref.invalidate(productsProvider),
      ),
      _ => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Cargando'),
        ),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          eyebrow: 'Lo más pedido',
          title: 'Nuestros favoritos',
          action: TextButton(
            onPressed: () => context.go(AppRoutes.catalog),
            child: const Text('Ver carta'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        content,
      ],
    );
  }
}

/// Error dentro de una sección: más compacto que [ErrorView], que ocupa una pantalla entera.
class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
