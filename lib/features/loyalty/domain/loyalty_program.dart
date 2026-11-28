import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/core/network/json_parsing.dart';

/// Datos públicos de FORNEA CLUB (`GET /loyalty/program`): regla de puntos y recompensas.
class LoyaltyProgram {
  const LoyaltyProgram({
    required this.pointsPerEuro,
    required this.expiryDays,
    required this.rewards,
  });

  factory LoyaltyProgram.fromJson(Object? json) => switch (json) {
    {
      'pointsPerEuro': final String? pointsPerEuro,
      'expiryDays': final int? expiryDays,
      'rewards': final Object? rewards,
    } =>
      LoyaltyProgram(
        pointsPerEuro: pointsPerEuro,
        expiryDays: expiryDays,
        rewards: parseList(rewards, Reward.fromJson),
      ),
    _ => throw const UnexpectedResponseException(
      'Programa de puntos no válido',
    ),
  };

  /// Puntos por cada euro, tal como lo configura el local (`"1"`, `"0.5"`). `null` si el local
  /// aún no lo ha configurado.
  final String? pointsPerEuro;

  /// Días hasta que caducan los puntos; `null` si no caducan.
  final int? expiryDays;
  final List<Reward> rewards;
}

class Reward {
  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.benefit,
    required this.inStock,
  });

  factory Reward.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'name': final String name,
      'description': final String? description,
      'pointsCost': final int pointsCost,
      'benefit': final Object? benefit,
      'inStock': final bool inStock,
    } =>
      Reward(
        id: id,
        name: name,
        description: description,
        pointsCost: pointsCost,
        benefit: RewardBenefit.fromJson(benefit),
        inStock: inStock,
      ),
    _ => throw const UnexpectedResponseException('Recompensa no válida'),
  };

  final String id;
  final String name;
  final String? description;
  final int pointsCost;
  final RewardBenefit benefit;
  final bool inStock;
}

enum BenefitType {
  freeProduct,
  discount,

  /// Un tipo que esta versión de la app aún no conoce: se muestra sin detalle.
  unknown;

  static BenefitType fromJson(String value) => switch (value) {
    'FREE_PRODUCT' => freeProduct,
    'DISCOUNT' => discount,
    _ => unknown,
  };
}

/// Qué da una recompensa: un producto gratis o un descuento.
class RewardBenefit {
  const RewardBenefit({
    required this.type,
    required this.productName,
    required this.amount,
  });

  factory RewardBenefit.fromJson(Object? json) => switch (json) {
    {
      'type': final String type,
      'productName': final String? productName,
      'amount': final String? amount,
    } =>
      RewardBenefit(
        type: BenefitType.fromJson(type),
        productName: productName,
        amount: amount,
      ),
    _ => throw const UnexpectedResponseException('Beneficio no válido'),
  };

  final BenefitType type;
  final String? productName;

  /// Importe del descuento (`"5.00"`), si lo es.
  final String? amount;
}
