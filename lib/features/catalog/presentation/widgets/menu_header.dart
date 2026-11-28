import 'package:fornea/core/motion/motion.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/section_heading.dart';
import 'package:material_ui/material_ui.dart';

/// Cabecera de la Carta con los textos y la imagen de la web, sobre fondo crema.
class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.creamSoft,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              eyebrow: 'Carta',
              title: 'Nuestra carta',
              description:
                  'Elige tu pizza, personalízala y añádela a tu pedido. '
                  'Precios con IVA incluido.',
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              // Altura limitada para que los productos asomen sin tener que desplazarse mucho.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                // Como en la web: crece al entrar (1,2 s) y después «respira» (8 s).
                child: Entrance(
                  duration: const Duration(milliseconds: 1200),
                  builder: (t, child) => Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.88 + 0.12 * t,
                      child: child,
                    ),
                  ),
                  child: LoopingMotion(
                    period: const Duration(seconds: 8),
                    builder: (t, child) =>
                        Transform.scale(scale: 0.965 + 0.065 * t, child: child),
                    child: Image.asset(
                      'assets/images/menu_banner.webp',
                      // Decorativa, como en la web (alt vacío): los lectores de pantalla la
                      // saltan.
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
