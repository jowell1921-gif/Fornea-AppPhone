import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/error_view.dart';
import 'package:fornea/core/widgets/info_tag.dart';
import 'package:fornea/core/widgets/loading_view.dart';
import 'package:fornea/dev/sample_data_banner.dart';
import 'package:fornea/features/catalog/presentation/widgets/product_card.dart';
import 'package:material_ui/material_ui.dart';

/// SOLO DESARROLLO: catálogo de componentes reutilizables con DATOS DE EJEMPLO.
///
/// La ruta solo se registra en modo debug (`kDebugMode`), así que esta pantalla no existe en la
/// app publicada. Sirve para revisar el diseño de los componentes sin depender del backend.
class ComponentsPreviewScreen extends StatelessWidget {
  const ComponentsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(title, style: textTheme.titleLarge),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Componentes (desarrollo)')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SampleDataBanner(),
          section('Tarjeta de producto'),
          ProductCard(
            name: 'Pizza de ejemplo',
            description: 'Descripción de ejemplo para revisar el diseño.',
            price: '9.50',
            ingredients: const ['Tomate', 'Mozzarella', 'Albahaca'],
            allergens: const ['Gluten', 'Lácteos'],
            vegetarian: true,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          ProductCard(
            name: 'Producto no disponible',
            description: 'Así se ve un producto agotado.',
            price: '12',
            onTap: () {},
            available: false,
          ),
          section('Precios'),
          Text(
            '"9.50" → ${formatEuro('9.50')}   ·   '
            '"12" → ${formatEuro('12')}   ·   '
            '"1234.5" → ${formatEuro('1234.5')}',
          ),
          section('Etiquetas'),
          const Wrap(
            spacing: AppSpacing.sm,
            children: [
              InfoTag(label: 'Vegetariano', icon: Icons.eco),
              InfoTag(label: 'No disponible', outlined: true),
            ],
          ),
          section('Cargando'),
          const SizedBox(height: 96, child: LoadingView()),
          section('Error'),
          SizedBox(
            height: 320,
            child: ErrorView(
              message: 'No hemos podido cargar la carta. Revisa tu conexión.',
              onRetry: () {},
            ),
          ),
        ],
      ),
    );
  }
}
