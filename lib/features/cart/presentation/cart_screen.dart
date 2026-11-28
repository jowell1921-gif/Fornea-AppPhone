import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/empty_state.dart';
import 'package:fornea/core/widgets/error_view.dart';
import 'package:fornea/core/widgets/loading_view.dart';
import 'package:fornea/features/cart/domain/cart_line.dart';
import 'package:fornea/features/cart/presentation/cart_controller.dart';
import 'package:fornea/features/cart/presentation/cart_quote_provider.dart';
import 'package:fornea/features/cart/presentation/widgets/cart_line_tile.dart';
import 'package:fornea/features/cart/presentation/widgets/cart_totals.dart';
import 'package:fornea/features/checkout/domain/quote.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// «Tu pedido»: líneas del carrito, cantidades e importes calculados por el servidor.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tu pedido')),
      body: switch (cart) {
        AsyncData(value: final lines) when lines.isEmpty => EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Tu pedido está vacío',
          message: 'Añade pizzas, entrantes, bebidas o postres.',
          action: FilledButton(
            onPressed: () => context.go(AppRoutes.catalog),
            child: const Text('Ver la carta'),
          ),
        ),
        AsyncData(value: final lines) => _CartContent(lines: lines),
        AsyncError() => ErrorView(
          message: 'No hemos podido abrir tu pedido guardado.',
          onRetry: () => ref.invalidate(cartProvider),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class _CartContent extends ConsumerWidget {
  const _CartContent({required this.lines});

  final List<CartLine> lines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(cartQuoteProvider);
    final cart = ref.read(cartProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final (index, line) in lines.indexed) ...[
                if (index > 0) const Divider(height: AppSpacing.lg),
                CartLineTile(
                  line: line,
                  lineTotal: quote.value?.lineFor(line.item)?.lineTotal,
                  onQuantityChanged: (value) => cart.setQuantity(line, value),
                  onRemove: () => _remove(context, ref, line),
                ),
              ],
              const Divider(height: AppSpacing.xl),
              _QuoteSummary(
                quote: quote,
                onRetry: () => ref.invalidate(cartQuoteProvider),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                child: TextButton(
                  onPressed: () => _clear(context, ref),
                  child: const Text('Vaciar pedido'),
                ),
              ),
            ],
          ),
        ),
        _CheckoutBar(quote: quote),
      ],
    );
  }

  /// Quitar y vaciar se pueden deshacer desde el aviso, en vez de pedir confirmación antes.
  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    CartLine line,
  ) async {
    final cart = ref.read(cartProvider.notifier);
    final before = lines;
    final messenger = ScaffoldMessenger.of(context);
    await cart.remove(line);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${line.name} quitado de tu pedido'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => cart.restore(before),
          ),
        ),
      );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final before = await cart.clear();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Has vaciado tu pedido'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => cart.restore(before),
          ),
        ),
      );
  }
}

/// Importes del servidor, o el motivo por el que no se pueden mostrar.
class _QuoteSummary extends StatelessWidget {
  const _QuoteSummary({required this.quote, required this.onRetry});

  final AsyncValue<Quote?> quote;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // El error va primero: si el último presupuesto falló, los importes anteriores ya no valen.
    return switch (quote) {
      AsyncValue(:final error?) when isRejectedSelection(error) => Text(
        'No hemos podido calcular el importe. ${quoteErrorMessage(error)} '
        'Alguno de los productos puede haber cambiado: quítalo y vuelve a añadirlo.',
        style: TextStyle(color: theme.colorScheme.error),
      ),
      AsyncValue(:final error?) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loadErrorMessage(error)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
      AsyncValue(value: final quote?) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CartTotals(quote: quote),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Los gastos de envío se calculan al finalizar el pedido, según tu dirección.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      _ => const Text('Calculando importe…'),
    };
  }
}

/// Botón fijo al pie con el total del servidor.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.quote});

  final AsyncValue<Quote?> quote;

  @override
  Widget build(BuildContext context) {
    final total = quote.hasError ? null : quote.value?.totals.total;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            // Solo con un importe válido del servidor.
            onPressed: total == null
                ? null
                // Finalizar exige sesión (Fase 5) y el checkout llega en la Fase 6.
                : () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Finalizar el pedido llegará con el inicio de sesión y el pago '
                        '(Fases 5 y 6).',
                      ),
                    ),
                  ),
            child: Text(
              total == null
                  ? 'FINALIZAR PEDIDO'
                  : 'FINALIZAR PEDIDO · ${formatEuro(total)}',
            ),
          ),
        ),
      ),
    );
  }
}
