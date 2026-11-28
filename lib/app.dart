import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/navigation/app_router.dart';
import 'package:fornea/core/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

/// Widget raíz de la aplicación: aplica el tema de FORNEA y conecta la navegación.
///
/// `main.dart` solo arranca la app; así la inicialización queda separada de la interfaz.
class ForneaApp extends ConsumerWidget {
  const ForneaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FORNEA',
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
