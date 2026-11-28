import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// Tema de Material 3 con la identidad de FORNEA.
///
/// Solo hay tema claro porque la web tampoco tiene modo oscuro. Los widgets leen colores y
/// estilos con `Theme.of(context)`, nunca con valores escritos a mano, para que un cambio de
/// marca se haga solo aquí.
abstract final class AppTheme {
  static ThemeData light() {
    // `fromSeed` genera los tonos intermedios que Material necesita; encima se fijan los
    // colores que deben coincidir exactamente con la web.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.tomato,
      primary: AppColors.tomatoStrong,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.cream,
      onPrimaryContainer: AppColors.charcoal,
      secondary: AppColors.charcoal,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.cream,
      onSecondaryContainer: AppColors.charcoal,
      tertiary: AppColors.gold,
      onTertiary: AppColors.charcoal,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.charcoal,
      onSurfaceVariant: AppColors.inkMuted,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.creamSoft,
      surfaceContainer: AppColors.creamSoft,
      surfaceContainerHigh: AppColors.cream,
      surfaceContainerHighest: AppColors.cream,
      outline: AppColors.input,
      outlineVariant: AppColors.border,
    );

    final base = ThemeData(colorScheme: colorScheme, fontFamily: AppFonts.body);
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
    );
    const buttonSize = Size(64, kMinTouchTarget);
    final buttonText = base.textTheme.labelLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      textTheme: AppTypography.textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: shape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: shape,
          textStyle: buttonText,
          foregroundColor: AppColors.charcoal,
          side: const BorderSide(color: AppColors.input),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          shape: shape,
          textStyle: buttonText,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: const InputDecorationThemeData(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          borderSide: BorderSide(color: AppColors.input),
        ),
      ),
      // Barra inferior blanca; la pestaña activa se marca con una píldora crema y texto en negrita.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.cream,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => base.textTheme.labelMedium?.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
    );
  }
}
