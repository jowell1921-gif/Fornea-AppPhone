import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/features/loyalty/domain/loyalty_account.dart';
import 'package:fornea/features/orders/domain/order_summary.dart';
import 'package:fornea/features/profile/domain/profile.dart';

/// Datos del cliente que exigen sesión: perfil, puntos y pedidos.
///
/// Es `null` mientras no hay sesión. Hasta la Fase 5 (inicio de sesión) siempre lo es en la app
/// publicada; en desarrollo, `main.dart` inyecta una fuente de DATOS DE EJEMPLO para poder
/// diseñar las pantallas. En la Fase 5 se añadirá la implementación con la API real.
final accountSourceProvider = Provider<AccountSource?>((ref) => null);

abstract interface class AccountSource {
  /// Son datos de ejemplo (solo desarrollo): las pantallas deben avisarlo bien visible.
  bool get isSample;

  /// `GET /me`
  Future<Profile> fetchProfile();

  /// `GET /loyalty/account`
  Future<LoyaltyAccount> fetchLoyaltyAccount();

  /// `GET /loyalty/transactions` (los más recientes).
  Future<List<LoyaltyTransaction>> fetchRecentTransactions();

  /// `GET /orders/me`, del más reciente al más antiguo.
  Future<List<OrderSummary>> fetchOrders();
}
