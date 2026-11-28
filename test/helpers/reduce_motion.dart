import 'package:flutter_test/flutter_test.dart';

/// Simula «Quitar animaciones» activado en el sistema.
///
/// Las pantallas con animaciones continuas (la pizza que flota, la foto que respira) nunca
/// «terminan», así que `pumpAndSettle` no acabaría. Las pruebas de comportamiento las
/// desactivan; las animaciones se prueban aparte en `test/core/motion/`.
void reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
