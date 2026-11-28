import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/app.dart';
import 'package:fornea/core/network/retry_policy.dart';
import 'package:fornea/core/theme/font_licenses.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  registerFontLicenses();
  // ProviderScope guarda el estado de todos los providers de Riverpod; envuelve toda la app.
  runApp(const ProviderScope(retry: apiRetryPolicy, child: ForneaApp()));
}
