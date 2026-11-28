import 'package:flutter/services.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/features/home/presentation/widgets/club_teaser.dart';
import 'package:fornea/features/home/presentation/widgets/favourites_section.dart';
import 'package:fornea/features/home/presentation/widgets/home_hero.dart';
import 'package:material_ui/material_ui.dart';

/// Inicio: cabecera de marca, favoritos reales del backend y FORNEA CLUB.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // La cabecera es oscura: los iconos de la barra de estado pasan a claros en esta pantalla.
    // Para que sigan leyéndose al desplazar, una franja carbón fija queda detrás de ellos.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            const _HomeContent(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.paddingOf(context).top,
              child: const ColoredBox(color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        HomeHero(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: FavouritesSection(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: ClubTeaser(),
        ),
      ],
    );
  }
}
