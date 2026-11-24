import 'package:material_ui/material_ui.dart';

/// Widget raíz de la aplicación.
///
/// Aquí se conectarán el tema de FORNEA (tarea 3.3) y la navegación (tarea 3.4).
/// `main.dart` solo arranca la app; así la inicialización queda separada de la interfaz.
class ForneaApp extends StatelessWidget {
  const ForneaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FORNEA',
      home: Scaffold(body: Center(child: Text('FORNEA'))),
    );
  }
}
