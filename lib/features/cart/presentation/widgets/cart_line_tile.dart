import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/product_image.dart';
import 'package:fornea/core/widgets/quantity_stepper.dart';
import 'package:fornea/features/cart/domain/cart_limits.dart';
import 'package:fornea/features/cart/domain/cart_line.dart';
import 'package:material_ui/material_ui.dart';

/// Una línea del pedido: foto, nombre, opciones, nota, importe del servidor y controles.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    required this.line,
    required this.lineTotal,
    required this.onQuantityChanged,
    required this.onRemove,
    super.key,
  });

  final CartLine line;

  /// Importe de la línea según el presupuesto; `null` mientras no llega.
  final String? lineTotal;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final lineTotal = this.lineTotal;
    final notes = line.item.notes;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: ProductImage(url: line.imageUrl, alt: line.imageAlt),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(line.name, style: theme.textTheme.titleMedium),
                  ),
                  if (lineTotal != null)
                    Text(
                      formatEuro(lineTotal),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              if (line.optionSummary.isNotEmpty)
                Text(line.optionSummary, style: muted),
              if (notes != null) Text('«$notes»', style: muted),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  QuantityStepper(
                    value: line.item.quantity,
                    max: maxLineQuantity,
                    itemLabel: line.name,
                    onChanged: onQuantityChanged,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Quitar ${line.name} del pedido',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
