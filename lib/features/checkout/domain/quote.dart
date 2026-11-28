import 'package:flutter/foundation.dart';
import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/core/network/json_parsing.dart';

/// Una línea que se pide presupuestar: producto, opciones, cantidad y nota.
///
/// Solo identificadores y cantidades: la API rechaza cualquier precio que envíe el cliente.
/// Tiene igualdad por valor (dos líneas iguales son «la misma»), lo que permite usarla como
/// clave de un provider `family` y emparejarla con las líneas del presupuesto.
@immutable
class QuoteItem {
  QuoteItem({
    required this.productId,
    required List<String> optionIds,
    required this.quantity,
    String? notes,
  }) : optionIds = List.unmodifiable([...optionIds]..sort()),
       notes = (notes == null || notes.trim().isEmpty) ? null : notes.trim();

  final String productId;

  /// Ordenados, para que el orden en que se marcaron no cree líneas distintas.
  final List<String> optionIds;
  final int quantity;
  final String? notes;

  Map<String, Object?> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'optionIds': optionIds,
    'notes': ?notes,
  };

  @override
  bool operator ==(Object other) =>
      other is QuoteItem &&
      other.productId == productId &&
      other.quantity == quantity &&
      other.notes == notes &&
      listEquals(other.optionIds, optionIds);

  @override
  int get hashCode =>
      Object.hash(productId, quantity, notes, Object.hashAll(optionIds));
}

/// Presupuesto del servidor (`POST /checkout/quote`): la única fuente de importes de la app.
class Quote {
  const Quote({
    required this.lines,
    required this.discounts,
    required this.totals,
    required this.pointsToEarn,
  });

  factory Quote.fromJson(Object? json) => switch (json) {
    {
      'lines': final Object? lines,
      'discounts': final Object? discounts,
      'totals': final Object? totals,
      'pointsToEarn': final int pointsToEarn,
    } =>
      Quote(
        lines: parseList(lines, QuoteLine.fromJson),
        discounts: parseList(discounts, QuoteDiscount.fromJson),
        totals: QuoteTotals.fromJson(totals),
        pointsToEarn: pointsToEarn,
      ),
    _ => throw const UnexpectedResponseException('Presupuesto no válido'),
  };

  final List<QuoteLine> lines;
  final List<QuoteDiscount> discounts;
  final QuoteTotals totals;

  /// Estimación de puntos de FORNEA CLUB; la cifra definitiva la decide el servidor al
  /// completar el pedido.
  final int pointsToEarn;

  /// La línea del presupuesto que corresponde a [item], si la hay.
  ///
  /// Se busca por contenido y no por posición: mientras llega un presupuesto nuevo se sigue
  /// mostrando el anterior, y sus líneas pueden no coincidir ya con el carrito.
  QuoteLine? lineFor(QuoteItem item) {
    for (final line in lines) {
      if (line.item == item) return line;
    }
    return null;
  }
}

class QuoteLine {
  const QuoteLine({
    required this.item,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory QuoteLine.fromJson(Object? json) => switch (json) {
    {
      'productId': final String productId,
      'quantity': final int quantity,
      'notes': final String? notes,
      'unitPrice': final String unitPrice,
      'lineTotal': final String lineTotal,
      'options': final Object? options,
    } =>
      QuoteLine(
        item: QuoteItem(
          productId: productId,
          quantity: quantity,
          notes: notes,
          optionIds: parseList(options, _optionId),
        ),
        unitPrice: unitPrice,
        lineTotal: lineTotal,
      ),
    _ => throw const UnexpectedResponseException('Línea no válida'),
  };

  /// Qué se presupuestó, para emparejarla con el carrito.
  final QuoteItem item;

  /// Precio de una unidad con sus opciones, IVA incluido (`"11.50"`).
  final String unitPrice;

  /// Precio por la cantidad.
  final String lineTotal;

  static String _optionId(Object? json) => switch (json) {
    {'optionId': final String id} => id,
    _ => throw const UnexpectedResponseException('Opción no válida'),
  };
}

class QuoteDiscount {
  const QuoteDiscount({required this.description, required this.amount});

  factory QuoteDiscount.fromJson(Object? json) => switch (json) {
    {'description': final String description, 'amount': final String amount} =>
      QuoteDiscount(description: description, amount: amount),
    _ => throw const UnexpectedResponseException('Descuento no válido'),
  };

  final String description;

  /// Importe positivo que se resta (`"2.00"`).
  final String amount;
}

class QuoteTotals {
  const QuoteTotals({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  });

  factory QuoteTotals.fromJson(Object? json) => switch (json) {
    {
      'subtotal': final String subtotal,
      'discount': final String discount,
      'deliveryFee': final String deliveryFee,
      'tax': final String tax,
      'total': final String total,
    } =>
      QuoteTotals(
        subtotal: subtotal,
        discount: discount,
        deliveryFee: deliveryFee,
        tax: tax,
        total: total,
      ),
    _ => throw const UnexpectedResponseException('Totales no válidos'),
  };

  final String subtotal;
  final String discount;
  final String deliveryFee;

  /// IVA contenido en el total (los precios ya lo incluyen).
  final String tax;
  final String total;
}
