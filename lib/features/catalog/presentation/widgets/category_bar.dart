import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/features/catalog/domain/category.dart';
import 'package:material_ui/material_ui.dart';

/// Barra horizontal de categorías que se queda fija arriba al desplazar la carta, como la
/// barra «sticky» de la web. Al pulsar una categoría se avisa con [onSelected].
///
/// Es un [SliverPersistentHeaderDelegate]: el objeto que describe a un `SliverPersistentHeader`
/// cuánto mide y qué pinta.
class CategoryBarDelegate extends SliverPersistentHeaderDelegate {
  CategoryBarDelegate({required this.categories, required this.onSelected});

  /// Altura fija: botón táctil + margen arriba y abajo + la línea inferior.
  static const double height = kMinTouchTarget + AppSpacing.sm * 2 + 1;

  final List<Category> categories;
  final ValueChanged<Category> onSelected;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Semantics(
        label: 'Categorías de la carta',
        container: true,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final category = categories[index];
            return OutlinedButton(
              onPressed: () => onSelected(category),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                foregroundColor: AppColors.charcoal,
                side: BorderSide(
                  color: AppColors.charcoal.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              child: Text(category.name),
            );
          },
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(CategoryBarDelegate oldDelegate) =>
      oldDelegate.categories != categories;
}
