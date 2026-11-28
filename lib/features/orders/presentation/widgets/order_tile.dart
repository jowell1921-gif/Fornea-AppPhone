import 'package:fornea/core/formatting/dates.dart';
import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/info_tag.dart';
import 'package:fornea/features/orders/domain/order_summary.dart';
import 'package:material_ui/material_ui.dart';

/// Resumen de un pedido, como en «Mis pedidos» de la web: número, modalidad, fecha, unidades,
/// estado e importe.
class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, super.key});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final items = order.itemCount == 1
        ? '1 producto'
        : '${order.itemCount} productos';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pedido nº ${order.orderNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' · ${order.type.label}', style: muted),
                      ],
                    ),
                  ),
                  Text(
                    '${formatShortDate(order.createdAt)} · $items',
                    style: muted,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Los pedidos en curso destacan; los terminados van solo con borde.
                  InfoTag(
                    label: order.status.label,
                    outlined: order.status.isFinished,
                  ),
                ],
              ),
            ),
            Text(
              formatEuro(order.total),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
