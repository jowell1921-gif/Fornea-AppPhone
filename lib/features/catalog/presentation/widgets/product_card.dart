import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/dashed_outline.dart';
import 'package:fornea/core/widgets/info_tag.dart';
import 'package:fornea/core/widgets/product_image.dart';
import 'package:fornea/features/catalog/domain/product.dart';
import 'package:material_ui/material_ui.dart';

/// Tarjeta de producto de la carta, con la misma información que la tarjeta de la web.
///
/// [ProductCard.fromProduct] la construye a partir del modelo de la API; el constructor con
/// datos sueltos se mantiene para el catálogo de componentes y las pruebas.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.name,
    required this.description,
    required this.price,
    required this.onTap,
    this.imageUrl,
    this.imageAlt = '',
    this.ingredients = const [],
    this.allergens = const [],
    this.vegetarian = false,
    this.available = true,
    super.key,
  });

  ProductCard.fromProduct(Product product, {required this.onTap, super.key})
    : name = product.name,
      description = product.description,
      price = product.price,
      imageUrl = product.image?.url,
      imageAlt = product.image?.alt ?? '',
      ingredients = product.ingredients,
      allergens = [for (final allergen in product.allergens) allergen.name],
      vegetarian = product.vegetarian,
      available = product.available;

  final String name;
  final String description;

  /// Precio mínimo tal como llega de la API (`"9.50"`); se muestra como «desde 9,50 €».
  final String price;
  final VoidCallback onTap;
  final String? imageUrl;
  final String imageAlt;
  final List<String> ingredients;
  final List<String> allergens;
  final bool vegetarian;
  final bool available;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );

    final card = Card(
      // Como en la web: lo no disponible va sobre crema y con borde discontinuo (lo pinta
      // [DashedOutline], por eso esta tarjeta no lleva borde propio).
      color: available ? null : colors.surfaceContainerLow,
      shape: available
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
            ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(url: imageUrl, alt: imageAlt, dimmed: !available),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(name, style: theme.textTheme.titleLarge),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'desde ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              TextSpan(
                                text: formatEuro(price),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(description, style: muted),
                    if (ingredients.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _LabeledList(
                        label: 'Ingredientes',
                        items: ingredients,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    if (vegetarian || !available || allergens.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (vegetarian)
                            const InfoTag(
                              label: 'Vegetariano',
                              icon: Icons.eco,
                            ),
                          if (!available)
                            const InfoTag(
                              label: 'No disponible',
                              outlined: true,
                            ),
                          if (allergens.isNotEmpty)
                            _LabeledList(
                              label: 'Alérgenos',
                              items: allergens,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return available ? card : DashedOutline(child: card);
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.url,
    required this.alt,
    required this.dimmed,
  });

  final String? url;
  final String alt;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // La tarjeta de un producto no disponible ya es crema, así que su recuadro pasa a blanco
    // para seguir distinguiéndose; la imagen se atenúa.
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: dimmed ? colors.surface : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Opacity(
        opacity: dimmed ? 0.5 : 1,
        child: ProductImage(url: url, alt: alt),
      ),
    );
  }
}

/// «Etiqueta: a, b, c» con la etiqueta en negrita.
class _LabeledList extends StatelessWidget {
  const _LabeledList({
    required this.label,
    required this.items,
    required this.style,
  });

  final String label;
  final List<String> items;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: items.join(', ')),
        ],
      ),
    );
  }
}
