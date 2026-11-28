import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/features/catalog/domain/product.dart';

import '../../../helpers/fake_api.dart';

String _resolve(String url) =>
    url.startsWith('/') ? 'https://web.test$url' : url;

void main() {
  test('lee el producto del ejemplo real de la API, con opciones', () {
    final json = productJson(
      id: '136a05d5-bcc8-497b-9fc9-c43446598e7b',
      categoryId: '8b824ff6-7360-47f4-94c4-01a8a7326e68',
      overrides: {
        'image': {
          'url': '/image/pizza-margherita-tabla.webp',
          'alt': '',
          'isPrimary': true,
        },
        'optionGroups': [
          {
            'id': '2ee9af3d-d69b-4305-9c86-116036c45661',
            'name': 'Tamaño',
            'kind': 'SIZE',
            'required': true,
            'minSelect': 1,
            'maxSelect': 1,
            'options': [
              {
                'id': '1655f333-f512-42f7-abd3-849803c0da74',
                'name': 'Familiar',
                'priceDelta': '4.00',
                'isDefault': false,
                'available': true,
              },
            ],
          },
        ],
      },
    );

    final product = Product.fromJson(json, resolveUrl: _resolve);

    expect(product.name, 'Margherita');
    expect(product.price, '9.50');
    expect(
      product.image?.url,
      'https://web.test/image/pizza-margherita-tabla.webp',
    );
    expect(product.ingredients, ['Tomate', 'Mozzarella']);
    expect(product.allergens.single.name, 'Gluten');
    final size = product.optionGroups.single;
    expect(size.kind, OptionKind.size);
    expect(size.options.single.priceDelta, '4.00');
  });

  test('ignora campos nuevos y acepta tipos de opción desconocidos', () {
    final json = productJson(
      id: 'p1',
      categoryId: 'c1',
      overrides: {
        'campoNuevo': 42,
        'optionGroups': [
          {
            'id': 'g1',
            'name': 'Salsa',
            'kind': 'SAUCE',
            'required': false,
            'minSelect': 0,
            'maxSelect': 1,
            'options': <Object?>[],
          },
        ],
      },
    );

    final product = Product.fromJson(json, resolveUrl: _resolve);

    expect(product.optionGroups.single.kind, OptionKind.unknown);
  });

  test('rechaza un producto al que le falta un campo obligatorio', () {
    final json = productJson(id: 'p1', categoryId: 'c1')..remove('price');

    expect(
      () => Product.fromJson(json, resolveUrl: _resolve),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });
}
