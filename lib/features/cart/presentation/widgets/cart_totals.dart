import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/features/checkout/domain/quote.dart';
import 'package:material_ui/material_ui.dart';

/// Desglose de importes tal como los calcula el servidor, igual que en la web. Los precios
/// incluyen IVA; aquí solo se muestran, no se suma nada.
class CartTotals extends StatelessWidget {
  const CartTotals({required this.quote, super.key});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = quote.totals;

    return Column(
      children: [
        _Row(label: 'Subtotal', value: formatEuro(totals.subtotal)),
        for (final discount in quote.discounts)
          _Row(
            label: discount.description,
            value: '-${formatEuro(discount.amount)}',
          ),
        const SizedBox(height: AppSpacing.xs),
        _Row(label: 'Total', value: formatEuro(totals.total), strong: true),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'IVA incluido (${formatEuro(totals.tax)}).',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = strong
        ? textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
        : textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
