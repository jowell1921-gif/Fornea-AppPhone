import 'package:fornea/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Etiqueta pequeña de información, como «Vegetariano» o «No disponible».
///
/// `outlined` la dibuja solo con borde, para estados menos destacados (igual que en la web).
class InfoTag extends StatelessWidget {
  const InfoTag({
    required this.label,
    this.icon,
    this.outlined = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final icon = this.icon;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: outlined ? null : colors.secondaryContainer,
        border: outlined ? Border.all(color: colors.outline) : null,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: colors.onSecondaryContainer),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
