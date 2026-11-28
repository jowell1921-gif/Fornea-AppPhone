import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/debounce.dart';
import 'package:fornea/features/cart/presentation/cart_controller.dart';
import 'package:fornea/features/checkout/data/checkout_repository.dart';
import 'package:fornea/features/checkout/domain/quote.dart';

/// Presupuesto del carrito calculado por el servidor, o `null` si está vacío.
///
/// Se vuelve a pedir cada vez que cambia el carrito (cantidades, líneas). Mientras llega el
/// nuevo, Riverpod conserva el anterior en `value`, así que los importes no desaparecen.
final cartQuoteProvider = FutureProvider.autoDispose<Quote?>((ref) async {
  final lines = await ref.watch(cartProvider.future);
  if (lines.isEmpty) return null;

  await debounce(ref);
  return ref.watch(checkoutRepositoryProvider).quote([
    for (final line in lines) line.item,
  ]);
});
