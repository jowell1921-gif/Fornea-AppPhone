import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/loyalty/domain/loyalty_program.dart';

final loyaltyRepositoryProvider = Provider<LoyaltyRepository>(
  (ref) => LoyaltyRepository(ref.watch(apiClientProvider)),
);

/// FORNEA CLUB en la API. Por ahora solo la parte pública; el saldo, los movimientos y los
/// canjes del cliente necesitan sesión y llegan en la Fase 5.
class LoyaltyRepository {
  const LoyaltyRepository(this._api);

  final ApiClient _api;

  Future<LoyaltyProgram> fetchProgram() async =>
      LoyaltyProgram.fromJson(await _api.get('/loyalty/program'));
}
