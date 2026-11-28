import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/features/cart/data/cart_storage.dart';
import 'package:fornea/features/cart/domain/cart_limits.dart';
import 'package:fornea/features/cart/domain/cart_line.dart';

/// El carrito de la app, compartido por la ficha, la pestaña Carrito y la barra inferior.
///
/// Es un `AsyncNotifier`: su estado inicial se carga del dispositivo (por eso es asíncrono) y
/// sus métodos lo cambian y lo vuelven a guardar. Es el «ViewModel» del carrito.
final cartProvider = AsyncNotifierProvider<CartController, List<CartLine>>(
  CartController.new,
);

/// Unidades en total, para el globo de la pestaña Carrito.
final cartItemCountProvider = Provider<int>((ref) {
  final lines = ref.watch(cartProvider).value ?? const <CartLine>[];
  return lines.fold(0, (sum, line) => sum + line.item.quantity);
});

class CartController extends AsyncNotifier<List<CartLine>> {
  @override
  Future<List<CartLine>> build() => ref.watch(cartStorageProvider).load();

  /// Añade [line]. Si ya hay una igual (mismo producto, opciones y nota), suma las cantidades
  /// sin pasar del máximo por línea. Devuelve `false` si el carrito ya tiene el máximo de
  /// líneas distintas.
  Future<bool> add(CartLine line) async {
    final lines = await future;
    final index = lines.indexWhere(line.sameChoiceAs);

    if (index == -1) {
      if (lines.length >= maxCartLines) return false;
      await _update([...lines, line.withQuantity(_clamp(line.item.quantity))]);
    } else {
      final existing = lines[index];
      await _update([
        for (final (i, item) in lines.indexed)
          i == index
              ? existing.withQuantity(
                  _clamp(existing.item.quantity + line.item.quantity),
                )
              : item,
      ]);
    }
    return true;
  }

  Future<void> setQuantity(CartLine line, int quantity) async {
    final lines = await future;
    await _update([
      for (final item in lines)
        item.sameChoiceAs(line) ? item.withQuantity(_clamp(quantity)) : item,
    ]);
  }

  Future<void> remove(CartLine line) async {
    final lines = await future;
    await _update([
      for (final item in lines)
        if (!item.sameChoiceAs(line)) item,
    ]);
  }

  /// Vacía el carrito y devuelve lo que tenía, para poder deshacerlo con [restore].
  Future<List<CartLine>> clear() async {
    final lines = await future;
    await _update(const []);
    return lines;
  }

  Future<void> restore(List<CartLine> lines) => _update(lines);

  Future<void> _update(List<CartLine> lines) async {
    // Primero la pantalla y después el disco: el cambio se ve al instante.
    state = AsyncData(List.unmodifiable(lines));
    await ref.read(cartStorageProvider).save(lines);
  }

  static int _clamp(int quantity) => quantity.clamp(1, maxLineQuantity);
}
