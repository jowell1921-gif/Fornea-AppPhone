import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/dashed_outline.dart';
import 'package:fornea/core/widgets/empty_state.dart';
import 'package:fornea/core/widgets/error_view.dart';
import 'package:fornea/core/widgets/loading_view.dart';
import 'package:fornea/core/widgets/section_heading.dart';
import 'package:fornea/features/catalog/domain/category.dart';
import 'package:fornea/features/catalog/domain/product.dart';
import 'package:fornea/features/catalog/presentation/catalog_providers.dart';
import 'package:fornea/features/catalog/presentation/widgets/category_bar.dart';
import 'package:fornea/features/catalog/presentation/widgets/menu_header.dart';
import 'package:fornea/features/catalog/presentation/widgets/product_card.dart';
import 'package:material_ui/material_ui.dart';

/// Carta: cabecera, barra fija de categorías y productos reales del backend por categoría.
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);

    // Se mira primero si hay datos (aunque sean de antes): si una recarga falla, la carta
    // que ya se veía se mantiene y el error se avisa aparte (ver [_refresh]).
    final error = categories.error ?? products.error;
    final Widget body = switch ((categories.value, products.value, error)) {
      (final cats?, final prods?, _) => _CatalogContent(
        categories: cats,
        products: prods,
        onRefresh: () => _refresh(context, ref),
      ),
      (_, _, final error?) => ErrorView(
        message: loadErrorMessage(error),
        onRetry: () {
          ref
            ..invalidate(categoriesProvider)
            ..invalidate(productsProvider);
        },
      ),
      _ => const LoadingView(),
    };

    // Sin AppBar, nadie fija el color de los iconos de la barra de estado: se piden oscuros
    // (si no, se quedarían los claros de Inicio, invisibles sobre blanco).
    // SafeArea: la carta empieza bajo la barra de estado; al desplazar no se mete debajo.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(body: SafeArea(bottom: false, child: body)),
    );
  }

  /// «Deslizar para recargar»: vuelve a pedir categorías y productos.
  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await Future.wait([
        ref.refresh(categoriesProvider.future),
        ref.refresh(productsProvider.future),
      ]);
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loadErrorMessage(error))));
    }
  }
}

class _CatalogContent extends StatefulWidget {
  const _CatalogContent({
    required this.categories,
    required this.products,
    required this.onRefresh,
  });

  final List<Category> categories;
  final List<Product> products;
  final RefreshCallback onRefresh;

  @override
  State<_CatalogContent> createState() => _CatalogContentState();
}

class _CatalogContentState extends State<_CatalogContent> {
  final _scrollController = ScrollController();

  /// Una clave por categoría para localizar su sección y desplazarse hasta ella.
  final _sectionKeys = <String, GlobalKey>{};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Desplaza la carta hasta la sección de [category], dejándola justo bajo la barra fija.
  void _scrollTo(Category category) {
    final renderObject = _sectionKeys[category.id]?.currentContext
        ?.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final position = _scrollController.position;
    // getOffsetToReveal ya tiene en cuenta la barra fija (no hay que restar su altura); solo se
    // deja un pequeño respiro para que el título no quede pegado a ella.
    final target =
        viewport.getOffsetToReveal(renderObject, 0).offset - AppSpacing.sm;
    final offset = target.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      _scrollController.jumpTo(offset);
    } else {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      for (final category in widget.categories)
        (
          category: category,
          products: widget.products
              .where((product) => product.categoryId == category.id)
              .toList(),
        ),
    ].where((section) => section.products.isNotEmpty).toList();

    if (sections.isEmpty) {
      return const EmptyState(
        icon: Icons.restaurant_menu,
        title: 'La carta está vacía',
        message: 'Vuelve en un rato: estamos preparando los productos.',
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverToBoxAdapter(child: MenuHeader()),
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryBarDelegate(
              // Solo las categorías que tienen productos, igual que las secciones.
              categories: [for (final section in sections) section.category],
              onSelected: _scrollTo,
            ),
          ),
          // Cada sección es un único bloque (no una lista perezosa) para que exista aunque
          // esté fuera de pantalla y se pueda saltar a ella. La carta es corta, así que
          // construirla entera no penaliza.
          for (final section in sections)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _MenuSection(
                  key: _sectionKeys.putIfAbsent(
                    section.category.id,
                    GlobalKey.new,
                  ),
                  category: section.category,
                  products: section.products,
                ),
              ),
            ),
          const SliverPadding(
            padding: EdgeInsets.all(AppSpacing.md),
            sliver: SliverToBoxAdapter(child: _AllergenNotice()),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.category,
    required this.products,
    super.key,
  });

  final Category category;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(title: category.name, description: category.description),
        const SizedBox(height: AppSpacing.md),
        for (final product in products)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ProductCard.fromProduct(
              product,
              // El detalle del producto llega en la tarea 4.4.
              onTap: () {},
            ),
          ),
      ],
    );
  }
}

/// Aviso de alérgenos con el mismo texto que la web.
class _AllergenNotice extends StatelessWidget {
  const _AllergenNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashedOutline(
      radius: AppRadius.md,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          'La información de alérgenos es orientativa en esta demostración. Si tienes '
          'alguna alergia o intolerancia, consúltanos antes de realizar el pedido.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
