import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/checkout/domain/quote.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(ref.watch(apiClientProvider)),
);

/// Presupuestos del servidor (`POST /checkout/quote`, público). Es la única fuente de precios
/// que muestra la app: aquí no se suma nada.
class CheckoutRepository {
  const CheckoutRepository(this._api);

  final ApiClient _api;

  /// Presupuesto de [items]. Por ahora siempre como recogida: el tipo de pedido solo cambia el
  /// envío, que se elegirá al finalizar el pedido (Fase 6). El servidor también valida cada
  /// línea: si algo no cumple las reglas, responde `422` (`INVALID_OPTIONS`,
  /// `PRODUCT_UNAVAILABLE`…).
  Future<Quote> quote(List<QuoteItem> items) async => Quote.fromJson(
    await _api.post(
      '/checkout/quote',
      body: {
        'items': [for (final item in items) item.toJson()],
        'type': 'PICKUP',
      },
    ),
  );
}
