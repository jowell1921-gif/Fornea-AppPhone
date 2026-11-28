import 'package:material_ui/material_ui.dart';

/// Indicador de carga centrado, para pantallas o secciones que esperan datos.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(semanticsLabel: 'Cargando'),
    );
  }
}
