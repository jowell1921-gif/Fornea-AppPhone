import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_theme.dart';
import 'package:fornea/core/theme/app_typography.dart';

void main() {
  final theme = AppTheme.light();

  test('los colores principales coinciden con la web', () {
    expect(theme.colorScheme.primary, AppColors.tomatoStrong);
    expect(theme.colorScheme.onSurface, AppColors.charcoal);
    expect(theme.scaffoldBackgroundColor, AppColors.white);
  });

  test('los títulos usan Barlow Condensed y el texto usa Inter', () {
    expect(theme.textTheme.displayLarge?.fontFamily, AppFonts.heading);
    expect(theme.textTheme.titleLarge?.fontFamily, AppFonts.heading);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.body);
  });
}
