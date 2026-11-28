import 'package:fornea/core/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Carrito del cliente.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: const EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'Tu carrito está vacío',
        message: 'Añade productos desde la carta.',
      ),
    );
  }
}
