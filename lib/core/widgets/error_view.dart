import 'package:fornea/core/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Error de carga con un mensaje para el cliente y, si se puede repetir, un botón «Reintentar».
///
/// El mensaje debe ser comprensible para el cliente; nunca el detalle técnico del servidor.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;

    return EmptyState(
      icon: Icons.error_outline,
      title: 'Algo ha fallado',
      message: message,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
    );
  }
}
