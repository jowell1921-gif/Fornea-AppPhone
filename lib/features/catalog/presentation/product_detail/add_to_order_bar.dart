import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/quantity_stepper.dart';
import 'package:fornea/features/cart/domain/cart_limits.dart';
import 'package:fornea/features/catalog/domain/product.dart';
import 'package:fornea/features/catalog/presentation/product_detail/line_price_provider.dart';
import 'package:fornea/features/checkout/domain/quote.dart';
import 'package:material_ui/material_ui.dart';

/// Barra fija al pie de la ficha: cantidad y «Añadir al pedido» con el precio que calcula el
/// servidor para la configuración elegida.
class AddToOrderBar extends ConsumerWidget {
  const AddToOrderBar({
    required this.product,
    required this.optionIds,
    required this.selectionComplete,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAdd,
    super.key,
  });

  final Product product;
  final List<String> optionIds;
  final bool selectionComplete;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: product.available
              ? _content(context, ref)
              : const SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: null,
                    child: Text('NO DISPONIBLE'),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref) {
    final request = QuoteItem(
      productId: product.id,
      optionIds: optionIds,
      quantity: quantity,
    );
    // Solo se pide precio cuando la selección está completa; si no, el servidor la rechazaría.
    final price = selectionComplete
        ? ref.watch(linePriceProvider(request))
        : null;

    final (String? total, bool canAdd, _Status status) = switch (price) {
      null => (null, false, const _Status('Elige las opciones obligatorias.')),
      AsyncData(:final value) => (
        value.lineTotal,
        true,
        const _Status('Precio con IVA incluido.'),
      ),
      AsyncError(:final error) when isRejectedSelection(error) => (
        null,
        false,
        _Status(quoteErrorMessage(error), isError: true),
      ),
      // Sin conexión se puede añadir igualmente: el carrito pedirá otra vez el precio.
      AsyncError(:final error) => (
        null,
        true,
        _Status(
          loadErrorMessage(error),
          isError: true,
          onRetry: () => ref.invalidate(linePriceProvider(request)),
        ),
      ),
      _ => (null, true, const _Status('Calculando precio…')),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            QuantityStepper(
              value: quantity,
              max: maxLineQuantity,
              itemLabel: product.name,
              onChanged: onQuantityChanged,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton(
                onPressed: canAdd ? onAdd : null,
                child: Text(
                  total == null ? 'AÑADIR' : 'AÑADIR · ${formatEuro(total)}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        status,
      ],
    );
  }
}

/// Línea pequeña bajo el botón: estado del precio o el motivo por el que no se puede añadir.
class _Status extends StatelessWidget {
  const _Status(this.message, {this.isError = false, this.onRetry});

  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onRetry = this.onRetry;

    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isError
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
