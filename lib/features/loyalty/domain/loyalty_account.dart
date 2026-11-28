import 'package:fornea/core/network/api_exception.dart';

/// Saldo de FORNEA CLUB del cliente (`GET /loyalty/account`, exige sesión).
class LoyaltyAccount {
  const LoyaltyAccount({
    required this.balance,
    required this.lifetimeEarned,
    required this.nextReward,
  });

  factory LoyaltyAccount.fromJson(Object? json) => switch (json) {
    {
      'balance': final int balance,
      'lifetimeEarned': final int lifetimeEarned,
      'nextReward': final Object? nextReward,
    } =>
      LoyaltyAccount(
        balance: balance,
        lifetimeEarned: lifetimeEarned,
        nextReward: nextReward == null ? null : NextReward.fromJson(nextReward),
      ),
    _ => throw const UnexpectedResponseException('Cuenta de puntos no válida'),
  };

  final int balance;
  final int lifetimeEarned;

  /// La recompensa más cercana que aún no alcanza; `null` si ya llega a todas o no hay.
  final NextReward? nextReward;
}

/// Progreso hacia la siguiente recompensa, calculado por el servidor.
class NextReward {
  const NextReward({
    required this.name,
    required this.pointsMissing,
    required this.progress,
  });

  factory NextReward.fromJson(Object? json) => switch (json) {
    {
      'name': final String name,
      'pointsMissing': final int pointsMissing,
      'progress': final num progress,
    } =>
      NextReward(
        name: name,
        pointsMissing: pointsMissing,
        progress: progress.toDouble().clamp(0, 1),
      ),
    _ => throw const UnexpectedResponseException(
      'Recompensa siguiente no válida',
    ),
  };

  final String name;
  final int pointsMissing;

  /// De 0 a 1, para la barra de progreso (no es dinero: aquí un `double` es correcto).
  final double progress;
}

enum TransactionType {
  earn('Puntos ganados'),
  redeem('Canje de recompensa'),
  reversal('Devolución de puntos'),
  adjustment('Ajuste'),
  expiration('Puntos caducados'),
  unknown('Movimiento');

  const TransactionType(this.label);

  /// Texto para el cliente, el mismo que la web.
  final String label;

  static TransactionType fromJson(String value) => switch (value) {
    'EARN' => earn,
    'REDEEM' => redeem,
    'REVERSAL' => reversal,
    'ADJUSTMENT' => adjustment,
    'EXPIRATION' => expiration,
    _ => unknown,
  };
}

/// Un movimiento de puntos (`GET /loyalty/transactions`).
class LoyaltyTransaction {
  const LoyaltyTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.orderNumber,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'type': final String type,
      'points': final int points,
      'orderNumber': final int? orderNumber,
      'createdAt': final String createdAt,
    } =>
      LoyaltyTransaction(
        id: id,
        type: TransactionType.fromJson(type),
        points: points,
        orderNumber: orderNumber,
        createdAt: DateTime.parse(createdAt),
      ),
    _ => throw const UnexpectedResponseException('Movimiento no válido'),
  };

  final String id;
  final TransactionType type;

  /// Positivo si suma, negativo si resta.
  final int points;
  final int? orderNumber;
  final DateTime createdAt;
}
