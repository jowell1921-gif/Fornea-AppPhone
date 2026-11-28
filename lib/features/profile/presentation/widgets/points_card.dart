import 'package:fornea/core/formatting/dates.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/features/loyalty/domain/loyalty_account.dart';
import 'package:fornea/features/loyalty/domain/points_text.dart';
import 'package:material_ui/material_ui.dart';

/// «Mis puntos FORNEA CLUB»: saldo, progreso hacia la siguiente recompensa y últimos
/// movimientos. Todo tal como lo da el servidor.
class PointsCard extends StatelessWidget {
  const PointsCard({
    required this.account,
    required this.transactions,
    required this.onOpenClub,
    super.key,
  });

  final LoyaltyAccount account;
  final List<LoyaltyTransaction> transactions;
  final VoidCallback onOpenClub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final next = account.nextReward;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis puntos FORNEA CLUB', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${account.balance}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: AppColors.tomatoDeep,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Flexible: con letra grande o pantalla estrecha, el texto baja de línea en
                // vez de salirse de la tarjeta.
                Flexible(
                  child: Text(
                    account.balance == 1
                        ? 'punto acumulado'
                        : 'puntos acumulados',
                    style: muted,
                  ),
                ),
              ],
            ),
            if (next != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: next.progress,
                  minHeight: 10,
                  color: AppColors.tomatoStrong,
                  backgroundColor: AppColors.cream,
                  semanticsLabel: 'Progreso hacia ${next.name}',
                  semanticsValue: '${(next.progress * 100).round()} %',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Te faltan ${pointsText(next.pointsMissing)} para «${next.name}».',
                style: muted,
              ),
            ],
            if (transactions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Últimos movimientos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (final movement in transactions)
                _Movement(movement: movement),
            ],
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onOpenClub,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Ver recompensas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Movement extends StatelessWidget {
  const _Movement({required this.movement});

  final LoyaltyTransaction movement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = movement.orderNumber;
    final points = movement.points;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movement.type.label),
                Text(
                  [
                    formatShortDate(movement.createdAt),
                    if (order != null) 'Pedido nº $order',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            points > 0 ? '+$points' : '$points',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: points > 0 ? AppColors.tomatoDeep : null,
            ),
          ),
        ],
      ),
    );
  }
}
