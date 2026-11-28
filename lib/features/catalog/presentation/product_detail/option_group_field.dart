import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/features/catalog/domain/option_selection.dart';
import 'package:fornea/features/catalog/domain/product.dart';
import 'package:material_ui/material_ui.dart';

/// Un grupo de opciones (tamaño, masa, extras…) con sus opciones disponibles.
///
/// Igual que en la web: opción única si el grupo es obligatorio y de una sola elección;
/// casillas en los demás, con las sobrantes desactivadas al llegar al máximo.
class OptionGroupField extends StatelessWidget {
  const OptionGroupField({
    required this.group,
    required this.selection,
    required this.onToggle,
    super.key,
  });

  final OptionGroup group;
  final OptionSelection selection;
  final ValueChanged<ProductOption> onToggle;

  String get _rule => switch (group) {
    OptionGroup(required: true) => 'obligatorio',
    OptionGroup(maxSelect: > 1) => 'hasta ${group.maxSelect}',
    _ => 'opcional',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final full = selection.isFull(group);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: group.name),
                TextSpan(
                  text: ' · $_rule',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final option in group.options)
          if (option.available)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: _OptionTile(
                option: option,
                singleChoice: group.isSingleChoice,
                selected: selection.isSelected(group, option),
                enabled: !full || selection.isSelected(group, option),
                onTap: () => onToggle(option),
              ),
            ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.singleChoice,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ProductOption option;
  final bool singleChoice;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final delta = formatPriceDelta(option.priceDelta);
    final icon = switch ((singleChoice, selected)) {
      (true, true) => Icons.radio_button_checked,
      (true, false) => Icons.radio_button_unchecked,
      (false, true) => Icons.check_box,
      (false, false) => Icons.check_box_outline_blank,
    };

    // MergeSemantics junta icono y textos en un único elemento para el lector de pantalla,
    // que lo anuncia como casilla u opción única, marcada o no.
    return MergeSemantics(
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: singleChoice,
        enabled: enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Material(
            color: selected ? AppColors.creamSoft : colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              side: BorderSide(
                color: selected ? AppColors.tomatoStrong : AppColors.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTouchTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + AppSpacing.xs,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: selected
                            ? AppColors.tomatoStrong
                            : colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                      Expanded(child: Text(option.name)),
                      if (delta != null)
                        Text(
                          delta,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
