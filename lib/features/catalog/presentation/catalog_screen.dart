import 'package:fornea/core/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Carta de productos. El contenido llegará del backend en la Fase 5.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carta')),
      body: const EmptyState(
        icon: Icons.restaurant_menu,
        title: 'La carta está en camino',
        message: 'Aquí verás las categorías y los productos.',
      ),
    );
  }
}
