import 'package:fornea/core/widgets/empty_state.dart';
import 'package:material_ui/material_ui.dart';

/// Perfil del cliente: datos, puntos de fidelización, sesión y textos legales.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: EmptyState(
        icon: Icons.person_outline,
        title: 'Tu cuenta',
        message: 'Aquí podrás iniciar sesión y consultar tus puntos.',
        // Las licencias OFL de las tipografías deben quedar accesibles desde la app.
        action: TextButton(
          onPressed: () => showLicensePage(context: context),
          child: const Text('Licencias de código abierto'),
        ),
      ),
    );
  }
}
