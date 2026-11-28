import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/features/cart/presentation/cart_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Estructura común de las pestañas principales: el contenido de la pestaña activa y la barra
/// de navegación inferior.
class MainShell extends ConsumerWidget {
  const MainShell({required this.navigationShell, super.key});

  /// Lo proporciona GoRouter: muestra la pestaña activa y permite cambiar de pestaña.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    // Pulsar la pestaña en la que ya estás vuelve a su pantalla inicial, como en las apps nativas.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Carta',
            ),
            NavigationDestination(
              // Globo con las unidades del carrito, como el contador del botón de la web.
              icon: Badge.count(
                count: cartCount,
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge.count(
                count: cartCount,
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_bag),
              ),
              label: 'Carrito',
              tooltip: cartCount > 0
                  ? 'Carrito, $cartCount unidades'
                  : 'Carrito, vacío',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pedidos',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
