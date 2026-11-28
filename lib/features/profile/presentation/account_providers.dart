import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/features/loyalty/domain/loyalty_account.dart';
import 'package:fornea/features/orders/domain/order_summary.dart';
import 'package:fornea/features/profile/data/account_source.dart';
import 'package:fornea/features/profile/domain/profile.dart';

/// ¿Hay datos de cliente que mostrar? Sin sesión, Perfil y Pedidos invitan a iniciarla.
final hasAccountProvider = Provider<bool>(
  (ref) => ref.watch(accountSourceProvider) != null,
);

/// Los datos del cliente son de ejemplo: se muestra el aviso «DATOS DE EJEMPLO».
final isSampleAccountProvider = Provider<bool>(
  (ref) => ref.watch(accountSourceProvider)?.isSample ?? false,
);

final profileProvider = FutureProvider<Profile?>((ref) async {
  final source = ref.watch(accountSourceProvider);
  return source?.fetchProfile();
});

final loyaltyAccountProvider = FutureProvider<LoyaltyAccount?>((ref) async {
  final source = ref.watch(accountSourceProvider);
  return source?.fetchLoyaltyAccount();
});

final recentTransactionsProvider = FutureProvider<List<LoyaltyTransaction>>((
  ref,
) async {
  final source = ref.watch(accountSourceProvider);
  return source == null ? const [] : source.fetchRecentTransactions();
});

final myOrdersProvider = FutureProvider<List<OrderSummary>>((ref) async {
  final source = ref.watch(accountSourceProvider);
  return source == null ? const [] : source.fetchOrders();
});
