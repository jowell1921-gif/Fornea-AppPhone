import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Cabecera de Inicio con la identidad de la web: fondo carbón, título de marca y la pizza
/// sobre un halo cálido.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: AppColors.charcoal,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PIZZERÍA · RECOGIDA Y DOMICILIO',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: 'Pizza de horno de leña, '),
                    TextSpan(
                      text: 'cuando quieras',
                      style: TextStyle(color: AppColors.tomato),
                    ),
                  ],
                ),
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.cream,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Pide online, elige recogida o entrega a domicilio y suma puntos en '
                'cada pedido con FORNEA CLUB.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.catalog),
                  child: const Text('PEDIR AHORA'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _HeroPizza(),
            ],
          ),
        ),
      ),
    );
  }
}

/// La pizza con el halo de la web. Entra con un leve aumento y fundido, salvo que el sistema
/// tenga las animaciones reducidas (accesibilidad).
class _HeroPizza extends StatelessWidget {
  const _HeroPizza();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final pizza = DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.tomato.withValues(alpha: 0.5),
            AppColors.gold.withValues(alpha: 0.16),
            AppColors.charcoal.withValues(alpha: 0),
          ],
          stops: const [0, 0.58, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          // Altura limitada para que la cabecera no ocupe toda la pantalla en móviles grandes.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Image.asset(
              'assets/images/hero_pizza.webp',
              semanticLabel: 'Pizza Margherita recién salida del horno de leña',
            ),
          ),
        ),
      ),
    );

    if (reduceMotion) return pizza;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
      ),
      child: pizza,
    );
  }
}
