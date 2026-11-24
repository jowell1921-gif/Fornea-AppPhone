import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Widget raíz de la aplicación: aplica el tema de FORNEA.
///
/// La navegación se conectará en la tarea 3.4. `main.dart` solo arranca la app; así la
/// inicialización queda separada de la interfaz.
class ForneaApp extends StatelessWidget {
  const ForneaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FORNEA',
      theme: AppTheme.light(),
      home: const _ThemePreview(),
    );
  }
}

/// TEMPORAL: muestra tipografías, colores y botones del tema para revisarlos en el emulador.
/// Se sustituirá por la navegación real en la tarea 3.4.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('FORNEA', style: textTheme.displayMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('PIZZA AL HORNO DE LEÑA', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Texto de interfaz en Inter. Así se verán las descripciones de los '
              'productos y los mensajes de la app.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {},
              child: const Text('Botón principal'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Botón secundario'),
            ),
            const SizedBox(height: AppSpacing.lg),
            const TextField(
              decoration: InputDecoration(labelText: 'Campo de texto'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Tarjeta', style: textTheme.titleLarge),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => showLicensePage(context: context),
              child: const Text('Ver licencias'),
            ),
          ],
        ),
      ),
    );
  }
}
