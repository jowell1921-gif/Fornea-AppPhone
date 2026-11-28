import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/checkout/domain/line_quote.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(ref.watch(apiClientProvider)),
);

/// Presupuestos del servidor (`POST /checkout/quote`, público). Es la única fuente de precios
/// que muestra la app: aquí no se suma nada.
class CheckoutRepository {
  const CheckoutRepository(this._api);

  final ApiClient _api;

  /// Precio de una sola línea. El tipo de pedido no cambia el precio de los productos (solo el
  /// envío), así que se usa recogida. El servidor también valida las opciones: si no cumplen
  /// las reglas del producto, responde `422` (`INVALID_OPTIONS`, `OPTION_UNAVAILABLE`…).
  Future<LineQuote> quoteLine(LineQuoteRequest line) async =>
      LineQuote.fromQuoteJson(
        await _api.post(
          '/checkout/quote',
          body: {
            'items': [line.toJson()],
            'type': 'PICKUP',
          },
        ),
      );
}
