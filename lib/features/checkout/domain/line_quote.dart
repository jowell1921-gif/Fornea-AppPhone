import 'package:flutter/foundation.dart';
import 'package:fornea/core/network/api_exception.dart';

/// Lo que se pide presupuestar: un producto con sus opciones y la cantidad.
///
/// Solo identificadores y cantidades: la API rechaza cualquier precio que envíe el cliente.
/// Tiene igualdad por valor (dos peticiones iguales son «la misma»), lo que permite usarla
/// como clave de un provider `family`.
@immutable
class LineQuoteRequest {
  LineQuoteRequest({
    required this.productId,
    required List<String> optionIds,
    required this.quantity,
  }) : optionIds = List.unmodifiable([...optionIds]..sort());

  final String productId;

  /// Ordenados, para que el orden en que se marcaron no cree peticiones distintas.
  final List<String> optionIds;
  final int quantity;

  Map<String, Object?> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'optionIds': optionIds,
  };

  @override
  bool operator ==(Object other) =>
      other is LineQuoteRequest &&
      other.productId == productId &&
      other.quantity == quantity &&
      listEquals(other.optionIds, optionIds);

  @override
  int get hashCode =>
      Object.hash(productId, quantity, Object.hashAll(optionIds));
}

/// Precio de una línea calculado por el servidor (`lines[0]` de `POST /checkout/quote`).
class LineQuote {
  const LineQuote({required this.unitPrice, required this.lineTotal});

  /// Lee la primera línea del presupuesto completo.
  factory LineQuote.fromQuoteJson(Object? json) => switch (json) {
    {
      'lines': [
        {
          'unitPrice': final String unitPrice,
          'lineTotal': final String lineTotal,
        },
        ...,
      ],
    } =>
      LineQuote(unitPrice: unitPrice, lineTotal: lineTotal),
    _ => throw const UnexpectedResponseException('Presupuesto no válido'),
  };

  /// Precio de una unidad con sus opciones, IVA incluido (`"11.50"`).
  final String unitPrice;

  /// Precio por la cantidad elegida.
  final String lineTotal;
}
