import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/app.dart';
import 'package:fornea/core/network/retry_policy.dart';
import 'package:fornea/core/theme/font_licenses.dart';
import 'package:fornea/dev/sample_account_source.dart';
import 'package:fornea/features/profile/data/account_source.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  registerFontLicenses();
  // ProviderScope guarda el estado de todos los providers de Riverpod; envuelve toda la app.
  runApp(
    ProviderScope(
      retry: apiRetryPolicy,
      overrides: [
        // SOLO DESARROLLO y hasta la Fase 5 (sesión): Perfil y Pedidos muestran DATOS DE
        // EJEMPLO para poder diseñarlos. `kDebugMode` es constante: en la versión publicada
        // esta línea y los datos de ejemplo desaparecen del binario.
        if (kDebugMode)
          accountSourceProvider.overrideWithValue(const SampleAccountSource()),
      ],
      child: const ForneaApp(),
    ),
  );
}
