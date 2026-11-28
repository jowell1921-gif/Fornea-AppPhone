import 'package:fornea/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// SOLO DESARROLLO: aviso visible de que lo que hay debajo son datos de ejemplo, no reales.
///
/// Se usa mientras una pantalla no puede mostrar datos reales (por ejemplo, porque necesita
/// iniciar sesión y eso llega en la Fase 5). Nunca aparece en la app publicada.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({
    this.detail = 'solo visible en modo desarrollo',
    super.key,
  });

  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.tertiary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
          child: Text(
            'DATOS DE EJEMPLO · $detail',
            style: TextStyle(
              color: colors.onTertiary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
