import 'package:flutter/foundation.dart';
import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/core/network/json_parsing.dart';
import 'package:fornea/features/checkout/domain/quote.dart';

/// Línea del carrito: qué quiere el cliente (producto, opciones, nota, cantidad) y unos datos
/// para mostrarla sin esperar al servidor (nombre, imagen, resumen de opciones).
///
/// **Nunca guarda precios**: los importes salen siempre del presupuesto del servidor.
class CartLine {
  const CartLine({
    required this.item,
    required this.name,
    required this.imageUrl,
    required this.imageAlt,
    required this.optionSummary,
  });

  factory CartLine.fromJson(Object? json) => switch (json) {
    {
      'productId': final String productId,
      'optionIds': final Object? optionIds,
      'quantity': final int quantity,
      'notes': final String? notes,
      'name': final String name,
      'imageUrl': final String? imageUrl,
      'imageAlt': final String imageAlt,
      'optionSummary': final String optionSummary,
    } =>
      CartLine(
        item: QuoteItem(
          productId: productId,
          optionIds: parseStringList(optionIds),
          quantity: quantity,
          notes: notes,
        ),
        name: name,
        imageUrl: imageUrl,
        imageAlt: imageAlt,
        optionSummary: optionSummary,
      ),
    _ => throw const UnexpectedResponseException('Línea del carrito no válida'),
  };

  /// Lo que se envía al servidor (producto, opciones, cantidad y nota).
  final QuoteItem item;
  final String name;
  final String? imageUrl;
  final String imageAlt;

  /// Opciones elegidas en texto («Familiar, Clásica, Mozzarella extra»).
  final String optionSummary;

  /// Dos líneas con el mismo producto, opciones y nota son la misma (se suman sus cantidades),
  /// igual que en la web.
  bool sameChoiceAs(CartLine other) =>
      other.item.productId == item.productId &&
      other.item.notes == item.notes &&
      listEquals(other.item.optionIds, item.optionIds);

  CartLine withQuantity(int quantity) => CartLine(
    item: QuoteItem(
      productId: item.productId,
      optionIds: item.optionIds,
      quantity: quantity,
      notes: item.notes,
    ),
    name: name,
    imageUrl: imageUrl,
    imageAlt: imageAlt,
    optionSummary: optionSummary,
  );

  Map<String, Object?> toJson() => {
    'productId': item.productId,
    'optionIds': item.optionIds,
    'quantity': item.quantity,
    'notes': item.notes,
    'name': name,
    'imageUrl': imageUrl,
    'imageAlt': imageAlt,
    'optionSummary': optionSummary,
  };
}
