import 'package:fornea/core/formatting/dates.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/features/profile/domain/profile.dart';
import 'package:material_ui/material_ui.dart';

/// Resumen de la cuenta como en la web: inicial, saludo, correo y antigüedad sobre carbón.
class AccountHeader extends StatelessWidget {
  const AccountHeader({required this.profile, super.key});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = profile.displayName;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.tomatoStrong,
                foregroundColor: AppColors.white,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOLA, ${name.toUpperCase()}',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.cream,
                    ),
                  ),
                  Text(
                    profile.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'Cliente desde ${formatMonthYear(profile.createdAt)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.cream.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
