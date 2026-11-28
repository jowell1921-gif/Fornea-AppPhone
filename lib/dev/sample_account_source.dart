import 'package:fornea/features/loyalty/domain/loyalty_account.dart';
import 'package:fornea/features/orders/domain/order_summary.dart';
import 'package:fornea/features/profile/data/account_source.dart';
import 'package:fornea/features/profile/domain/profile.dart';

/// SOLO DESARROLLO: DATOS DE EJEMPLO de un cliente ficticio, hasta tener sesión (Fase 5).
///
/// Se escriben con la misma forma JSON que devuelve la API y se leen con los mismos
/// `fromJson`, así que también comprueban los modelos. Solo se inyecta desde `main.dart` en
/// modo debug: en la app publicada no existe.
class SampleAccountSource implements AccountSource {
  const SampleAccountSource();

  @override
  bool get isSample => true;

  @override
  Future<Profile> fetchProfile() async => Profile.fromJson(const {
    'id': 'sample-user',
    'email': 'cliente@example.com',
    'fullName': 'Cliente de ejemplo',
    'username': 'ejemplo',
    'phone': null,
    'profileComplete': true,
    'marketingConsent': false,
    'roles': <String>[],
    'permissions': <String>[],
    'createdAt': '2026-03-14T10:00:00.000Z',
  });

  @override
  Future<LoyaltyAccount> fetchLoyaltyAccount() async =>
      LoyaltyAccount.fromJson(const {
        'balance': 180,
        'lifetimeEarned': 280,
        'pointsPerEuro': '1',
        'expiryDays': null,
        'availableRewards': 1,
        'nextReward': {
          'id': 'sample-reward',
          'name': 'Recompensa de ejemplo',
          'pointsCost': 250,
          'pointsMissing': 70,
          'progress': 0.72,
        },
      });

  @override
  Future<List<LoyaltyTransaction>> fetchRecentTransactions() async => [
    for (final json in const [
      {
        'id': 't3',
        'type': 'EARN',
        'points': 31,
        'balanceAfter': 180,
        'reason': null,
        'orderNumber': 1042,
        'createdAt': '2026-11-20T20:15:00.000Z',
      },
      {
        'id': 't2',
        'type': 'REDEEM',
        'points': -100,
        'balanceAfter': 149,
        'reason': null,
        'orderNumber': null,
        'createdAt': '2026-11-02T19:00:00.000Z',
      },
      {
        'id': 't1',
        'type': 'EARN',
        'points': 45,
        'balanceAfter': 249,
        'reason': null,
        'orderNumber': 1031,
        'createdAt': '2026-10-30T21:40:00.000Z',
      },
    ])
      LoyaltyTransaction.fromJson(json),
  ];

  @override
  Future<List<OrderSummary>> fetchOrders() async => [
    for (final json in const [
      {
        'id': 'o4',
        'orderNumber': 1045,
        'status': 'PREPARING',
        'type': 'PICKUP',
        'total': '27.00',
        'itemCount': 2,
        'createdAt': '2026-11-28T13:05:00.000Z',
      },
      {
        'id': 'o3',
        'orderNumber': 1042,
        'status': 'COMPLETED',
        'type': 'DELIVERY',
        'total': '31.50',
        'itemCount': 3,
        'createdAt': '2026-11-20T19:30:00.000Z',
      },
      {
        'id': 'o2',
        'orderNumber': 1031,
        'status': 'COMPLETED',
        'type': 'PICKUP',
        'total': '45.00',
        'itemCount': 4,
        'createdAt': '2026-10-30T20:10:00.000Z',
      },
      {
        'id': 'o1',
        'orderNumber': 1020,
        'status': 'CANCELLED',
        'type': 'PICKUP',
        'total': '12.50',
        'itemCount': 1,
        'createdAt': '2026-10-12T18:45:00.000Z',
      },
    ])
      OrderSummary.fromJson(json),
  ];
}
