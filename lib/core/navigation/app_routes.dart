/// Rutas de la app en un único sitio, para no repetir cadenas por el código.
abstract final class AppRoutes {
  static const String home = '/';
  static const String catalog = '/catalog';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  /// Ficha de un producto. Fuera de las pestañas: se abre a pantalla completa, sin la barra
  /// inferior, y se puede abrir desde cualquier pestaña.
  static const String productPattern = '/product/:id';
  static String product(String id) => '/product/${Uri.encodeComponent(id)}';

  /// FORNEA CLUB (pantalla completa, se abre desde Inicio y Perfil).
  static const String club = '/club';

  /// Solo existe en modo debug.
  static const String devComponents = '/dev/components';
}
