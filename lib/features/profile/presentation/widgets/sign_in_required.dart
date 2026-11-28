import 'package:fornea/core/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Lo que ve quien no ha iniciado sesión en una pantalla que la necesita (Perfil, Pedidos).
///
/// El inicio de sesión llega en la Fase 5: hasta entonces el botón está desactivado.
class SignInRequired extends StatelessWidget {
  const SignInRequired({required this.icon, required this.message, super.key});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: 'Inicia sesión',
      message: '$message Usa la misma cuenta que en la web.',
      action: const FilledButton(
        // Se activará con el inicio de sesión (Fase 5).
        onPressed: null,
        child: Text('INICIAR SESIÓN · MUY PRONTO'),
      ),
    );
  }
}
