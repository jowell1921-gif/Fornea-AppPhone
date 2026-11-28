import 'package:fornea/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Encabezado de sección como el de la web: antetítulo opcional, título en mayúsculas (la web
/// los pone así por CSS), descripción opcional y una acción a la derecha (por ejemplo,
/// «Ver carta»).
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    this.eyebrow,
    this.description,
    this.action,
    this.onDark = false,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? description;
  final Widget? action;

  /// Colores para fondos oscuros (antetítulo dorado y título crema).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final eyebrow = this.eyebrow;
    final description = this.description;
    final action = this.action;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: onDark ? colors.tertiary : colors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              Semantics(
                header: true,
                child: Text(
                  title.toUpperCase(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: onDark ? colors.primaryContainer : null,
                  ),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: onDark
                        ? colors.primaryContainer.withValues(alpha: 0.85)
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.sm), action],
      ],
    );
  }
}
