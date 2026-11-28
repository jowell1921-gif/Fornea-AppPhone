import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/section_heading.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Presentación breve de FORNEA CLUB, como en la web. Lleva a la pantalla del club.
class ClubTeaser extends StatelessWidget {
  const ClubTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              eyebrow: 'Fidelización',
              title: 'FORNEA CLUB',
              onDark: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Suma puntos en cada pedido y canjéalos por recompensas.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.cream.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.charcoal,
              ),
              onPressed: () => context.push(AppRoutes.club),
              icon: const Icon(Icons.card_giftcard),
              label: const Text('DESCUBRIR EL CLUB'),
            ),
          ],
        ),
      ),
    );
  }
}
