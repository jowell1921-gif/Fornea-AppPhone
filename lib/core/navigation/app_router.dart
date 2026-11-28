import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/navigation/main_shell.dart';
import 'package:fornea/core/navigation/not_found_screen.dart';
import 'package:fornea/dev/components_preview_screen.dart';
import 'package:fornea/features/cart/presentation/cart_screen.dart';
import 'package:fornea/features/catalog/presentation/catalog_screen.dart';
import 'package:fornea/features/home/presentation/home_screen.dart';
import 'package:fornea/features/orders/presentation/orders_screen.dart';
import 'package:fornea/features/profile/presentation/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// El router se expone como provider para que, en la Fase 5, pueda leer el estado de la sesión
/// (por ejemplo, para redirigir al inicio de sesión) sin depender de variables globales.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      // Cada rama es una pestaña con su propia pila de navegación. `indexedStack` mantiene vivas
      // las pestañas, así que al volver a una conserva su scroll y sus pantallas abiertas.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          _tab(AppRoutes.home, const HomeScreen()),
          _tab(AppRoutes.catalog, const CatalogScreen()),
          _tab(AppRoutes.cart, const CartScreen()),
          _tab(AppRoutes.orders, const OrdersScreen()),
          _tab(AppRoutes.profile, const ProfileScreen()),
        ],
      ),
      // `kDebugMode` es una constante: en la compilación de publicación esta ruta y su pantalla
      // se eliminan del binario.
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.devComponents,
          builder: (context, state) => const ComponentsPreviewScreen(),
        ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _tab(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
