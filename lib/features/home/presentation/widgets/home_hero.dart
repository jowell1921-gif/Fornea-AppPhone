import 'dart:math' as math;

import 'package:fornea/core/motion/motion.dart';
import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Cabecera de Inicio con la identidad de la web: fondo carbón, título de marca y la pizza
/// sobre un halo cálido, con las animaciones de la web.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: AppColors.charcoal,
      // El halo puede crecer al desplazar: se recorta para que no invada lo de debajo.
      child: ClipRect(
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
                _Depth(
                  // Texto: sube un poco al desplazar (la web: -44 px).
                  builder: (p, child) => Transform.translate(
                    offset: Offset(0, -22 * p),
                    child: child,
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
                        'Pide online, elige recogida o entrega a domicilio y suma puntos '
                        'en cada pedido con FORNEA CLUB.',
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
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _HeroPizza(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La pizza con su halo. Capas, de fuera a dentro, como en la web:
/// - halo: crece y se apaga al desplazar;
/// - entrada: aparece subiendo, creciendo y girando (1,1 s);
/// - profundidad: baja y gira un poco al desplazar;
/// - flotación: sube y baja 10 px sin parar (6 s).
class _HeroPizza extends StatelessWidget {
  const _HeroPizza();

  @override
  Widget build(BuildContext context) {
    final pizza = ConstrainedBox(
      // Altura limitada para que la cabecera no ocupe toda la pantalla en móviles grandes.
      constraints: const BoxConstraints(maxHeight: 200),
      child: Image.asset(
        'assets/images/hero_pizza.webp',
        semanticLabel: 'Pizza Margherita recién salida del horno de leña',
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: _Depth(
            // La web: escala 1,6 y opacidad 0,35; aquí, más suave.
            builder: (p, child) => Opacity(
              opacity: 1 - 0.4 * p,
              child: Transform.scale(scale: 1 + 0.3 * p, child: child),
            ),
            child: DecoratedBox(
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
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Entrance(
            duration: const Duration(milliseconds: 1100),
            builder: (t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - t)),
                child: Transform.rotate(
                  angle: _degrees(-4) * (1 - t),
                  child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
                ),
              ),
            ),
            child: _Depth(
              // La web: baja 70 px y gira 7°; aquí, la mitad.
              builder: (p, child) => Transform.translate(
                offset: Offset(0, 35 * p),
                child: Transform.rotate(angle: _degrees(3.5) * p, child: child),
              ),
              child: LoopingMotion(
                period: const Duration(seconds: 6),
                builder: (t, child) => Transform.translate(
                  offset: Offset(0, -10 + 20 * t),
                  child: child,
                ),
                child: pizza,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static double _degrees(double value) => value * math.pi / 180;
}

/// Efecto de profundidad ligado al desplazamiento de Inicio: [builder] recibe de 0 (arriba
/// del todo) a 1 (tras desplazar el 70 % de la altura de la pantalla), como la web.
class _Depth extends StatelessWidget {
  const _Depth({required this.builder, required this.child});

  final Widget Function(double progress, Widget child) builder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null || reduceMotionOf(context)) return child;

    // La posición de desplazamiento es un `Listenable`: solo se recalcula la transformación.
    return AnimatedBuilder(
      animation: position,
      builder: (context, child) {
        final range = position.hasViewportDimension
            ? position.viewportDimension * 0.7
            : 1.0;
        final pixels = position.hasPixels ? position.pixels : 0.0;
        return builder((pixels / range).clamp(0.0, 1.0), child!);
      },
      child: child,
    );
  }
}
