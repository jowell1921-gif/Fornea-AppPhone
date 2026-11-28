import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/features/catalog/presentation/catalog_providers.dart';

import '../../../helpers/fake_api.dart';

void main() {
  test('favoritos: solo destacados disponibles y como máximo 4', () async {
    Map<String, Object?> product(
      String id, {
      bool popular = true,
      bool available = true,
    }) => productJson(
      id: id,
      categoryId: 'c1',
      name: 'Pizza $id',
      overrides: {'popular': popular, 'available': available},
    );

    final adapter = FakeHttpAdapter({
      '/products': (
        status: 200,
        body: {
          'data': [
            product('1'),
            product('2', popular: false),
            product('3', available: false),
            product('4'),
            product('5'),
            product('6'),
            product('7'),
          ],
        },
      ),
    });
    // ProviderContainer es el ProviderScope sin interfaz: sirve para probar providers sueltos.
    final container = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(fakeDio(adapter))],
    );
    addTearDown(container.dispose);

    await container.read(productsProvider.future);
    final favourites = container.read(favouriteProductsProvider).requireValue;

    expect(favourites.map((p) => p.id), ['1', '4', '5', '6']);
  });
}
