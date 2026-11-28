import 'package:fornea/core/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Historial y estado de los pedidos del cliente.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Aún no tienes pedidos',
        message: 'Aquí verás el estado y el historial de tus pedidos.',
      ),
    );
  }
}
