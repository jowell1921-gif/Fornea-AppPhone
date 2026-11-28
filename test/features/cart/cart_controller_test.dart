import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/features/cart/data/cart_storage.dart';
import 'package:fornea/features/cart/domain/cart_line.dart';
import 'package:fornea/features/cart/presentation/cart_controller.dart';

import '../../helpers/memory_cart_storage.dart';

void main() {
  late MemoryCartStorage storage;
  late ProviderContainer container;

  setUp(() {
    storage = MemoryCartStorage();
    container = ProviderContainer(
      overrides: [cartStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
  });

  CartController cart() => container.read(cartProvider.notifier);
  Future<List<CartLine>> lines() => container.read(cartProvider.future);

  test('la misma elección se suma en una línea y no pasa de 20', () async {
    await cart().add(cartLine('p1', options: ['a', 'b'], quantity: 15));
    await cart().add(cartLine('p1', options: ['b', 'a'], quantity: 10));

    final result = await lines();
    expect(result, hasLength(1));
    expect(result.single.item.quantity, 20);
    expect(container.read(cartItemCountProvider), 20);
  });

  test('otra nota u otras opciones son otra línea', () async {
    await cart().add(cartLine('p1'));
    await cart().add(cartLine('p1', notes: 'sin albahaca'));
    await cart().add(cartLine('p1', options: ['a']));

    expect(await lines(), hasLength(3));
  });

  test(
    'cambiar cantidad, quitar y deshacer se guardan en el dispositivo',
    () async {
      await cart().add(cartLine('p1'));
      await cart().add(cartLine('p2'));
      final before = await lines();

      await cart().setQuantity(before.first, 3);
      expect(storage.saved.first.item.quantity, 3);

      await cart().remove(before.first);
      expect(storage.saved.map((l) => l.item.productId), ['p2']);

      await cart().restore(before);
      expect(storage.saved.map((l) => l.item.productId), ['p1', 'p2']);
    },
  );

  test('no admite más de 30 líneas distintas', () async {
    for (var i = 0; i < 30; i++) {
      expect(await cart().add(cartLine('p$i')), isTrue);
    }
    expect(await cart().add(cartLine('p30')), isFalse);
    expect(await lines(), hasLength(30));
  });

  test('una línea guardada se lee igual', () {
    final original = cartLine(
      'p1',
      options: ['b', 'a'],
      quantity: 2,
      notes: 'poco hecha',
    );
    final restored = CartLine.fromJson(original.toJson());

    expect(restored.item, original.item);
    expect(restored.name, original.name);
  });
}
