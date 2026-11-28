import 'package:fornea/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Encabezado de sección como el de la web: antetítulo pequeño, título y una acción opcional
/// a la derecha (por ejemplo, «Ver toda la carta»).
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.eyebrow,
    required this.title,
    this.action,
    this.onDark = false,
    super.key,
  });

  final String eyebrow;
  final String title;
  final Widget? action;

  /// Colores para fondos oscuros (antetítulo dorado y título crema).
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final action = this.action;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onDark ? colors.tertiary : colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: onDark ? colors.primaryContainer : null,
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: AppSpacing.sm), action],
      ],
    );
  }
}
