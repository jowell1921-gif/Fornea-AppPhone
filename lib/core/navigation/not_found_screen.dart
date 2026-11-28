import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/widgets/empty_state.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Se muestra si se abre una ruta que no existe (por ejemplo, un enlace antiguo).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.search_off,
        title: 'Página no encontrada',
        message: 'Esta sección no existe o ya no está disponible.',
        action: FilledButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text('Ir al inicio'),
        ),
      ),
    );
  }
}
