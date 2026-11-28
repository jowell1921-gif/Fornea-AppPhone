import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/empty_state.dart';
import 'package:fornea/core/widgets/error_view.dart';
import 'package:fornea/core/widgets/info_tag.dart';
import 'package:fornea/core/widgets/loading_view.dart';
import 'package:fornea/core/widgets/product_image.dart';
import 'package:fornea/features/cart/domain/cart_limits.dart';
import 'package:fornea/features/cart/domain/cart_line.dart';
import 'package:fornea/features/cart/presentation/cart_controller.dart';
import 'package:fornea/features/catalog/domain/option_selection.dart';
import 'package:fornea/features/catalog/domain/product.dart';
import 'package:fornea/features/catalog/presentation/catalog_providers.dart';
import 'package:fornea/features/catalog/presentation/product_detail/add_to_order_bar.dart';
import 'package:fornea/features/catalog/presentation/product_detail/option_group_field.dart';
import 'package:fornea/features/checkout/domain/quote.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Ficha de un producto: información completa y personalización (lo que en la web es la
/// ventana que se abre al pulsar una tarjeta).
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(productId));

    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.creamSoft),
      body: switch (product) {
        AsyncData(:final value) => _ProductDetail(product: value),
        AsyncError(error: ServerException(statusCode: 404)) => EmptyState(
          icon: Icons.search_off,
          title: 'Este producto ya no está en la carta',
          action: FilledButton(
            onPressed: () => context.go(AppRoutes.catalog),
            child: const Text('Ver la carta'),
          ),
        ),
        AsyncError(:final error) => ErrorView(
          message: loadErrorMessage(error),
          onRetry: () => ref.invalidate(productProvider(productId)),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

/// La ficha con su estado local: opciones elegidas, cantidad y nota. Es estado de la pantalla
/// (como un formulario): desaparece al cerrarla, igual que en la web.
class _ProductDetail extends ConsumerStatefulWidget {
  const _ProductDetail({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<_ProductDetail> {
  late OptionSelection _selection = OptionSelection.defaults(widget.product);
  int _quantity = 1;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              _Photo(product: product),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _Information(product: product),
              ),
              if (product.available) ...[
                for (final group in product.optionGroups)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: OptionGroupField(
                      group: group,
                      selection: _selection,
                      onToggle: (option) => setState(
                        () => _selection = _selection.toggle(group, option),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: TextField(
                    controller: _notes,
                    // El mismo límite que valida el backend para la nota de una línea.
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nota para este producto (opcional)',
                      hintText: 'Por ejemplo, sin albahaca',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        AddToOrderBar(
          product: product,
          optionIds: _selection.optionIds,
          selectionComplete: _selection.isCompleteFor(product),
          quantity: _quantity,
          onQuantityChanged: (value) => setState(() => _quantity = value),
          onAdd: _addToCart,
        ),
      ],
    );
  }

  /// Añade la configuración al carrito, cierra la ficha y avisa con acceso directo al pedido
  /// (en la web se cierra la ventana y se abre el panel del carrito).
  Future<void> _addToCart() async {
    final product = widget.product;
    final added = await ref
        .read(cartProvider.notifier)
        .add(
          CartLine(
            item: QuoteItem(
              productId: product.id,
              optionIds: _selection.optionIds,
              quantity: _quantity,
              notes: _notes.text,
            ),
            name: product.name,
            imageUrl: product.image?.url,
            imageAlt: product.image?.alt ?? product.name,
            optionSummary: [
              for (final option in _selection.chosenIn(product)) option.name,
            ].join(', '),
          ),
        );
    if (!mounted) return;

    // Se guardan antes de cerrar la ficha: después, este `context` ya no estará en pantalla.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.maybeOf(context);
    if (!added) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Tu pedido ya tiene $maxCartLines productos distintos, el máximo.',
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).maybePop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${product.name} añadido a tu pedido'),
        action: router == null
            ? null
            : SnackBarAction(
                label: 'Ver pedido',
                onPressed: () => router.go(AppRoutes.cart),
              ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.creamSoft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Opacity(
                opacity: product.available ? 1 : 0.5,
                child: ProductImage(
                  url: product.image?.url,
                  alt: product.image?.alt ?? product.name,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Information extends StatelessWidget {
  const _Information({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = TextStyle(color: theme.colorScheme.onSurfaceVariant);
    final allergens = [for (final a in product.allergens) a.name];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  product.name.toUpperCase(),
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'desde ',
                    style: theme.textTheme.bodySmall?.merge(muted),
                  ),
                  TextSpan(
                    text: formatEuro(product.price),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (product.vegetarian || !product.available) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (product.vegetarian)
                const InfoTag(label: 'Vegetariano', icon: Icons.eco),
              if (!product.available)
                const InfoTag(label: 'No disponible', outlined: true),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(product.description, style: theme.textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        if (product.ingredients.isNotEmpty) ...[
          _Fact(label: 'Ingredientes', value: product.ingredients.join(', ')),
          const SizedBox(height: AppSpacing.sm),
        ],
        _Fact(
          label: 'Alérgenos',
          value: allergens.isEmpty
              ? 'Sin alérgenos declarados'
              : allergens.join(', '),
        ),
      ],
    );
  }
}

/// «Etiqueta» en negrita y su valor debajo, como la lista de datos de la web.
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }
}
