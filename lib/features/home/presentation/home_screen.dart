import 'package:fornea/core/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Pantalla de inicio. Los destacados se añadirán en la Fase 4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FORNEA')),
      body: const EmptyState(
        icon: Icons.local_pizza_outlined,
        title: 'Bienvenido a FORNEA',
        message: 'Aquí verás las pizzas destacadas.',
      ),
    );
  }
}
