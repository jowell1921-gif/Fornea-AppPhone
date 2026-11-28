import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/features/catalog/data/catalog_repository.dart';

import '../../../helpers/fake_api.dart';

void main() {
  CatalogRepository repositoryWith(Map<String, FakeResponse> routes) =>
      CatalogRepository(
        ApiClient(fakeDio(FakeHttpAdapter(routes))),
        webBaseUrl: 'https://web.test',
      );

  test('lee categorías y productos y completa las URL relativas', () async {
    final repository = repositoryWith({
      '/categories': (
        status: 200,
        body: {
          'data': [categoryJson(id: 'c1', name: 'Pizzas')],
        },
      ),
      '/products': (
        status: 200,
        body: {
          'data': [
            productJson(
              id: 'p1',
              categoryId: 'c1',
              overrides: {
                'image': {
                  'url': '/image/a.webp',
                  'alt': 'A',
                  'isPrimary': true,
                },
              },
            ),
            productJson(
              id: 'p2',
              categoryId: 'c1',
              name: 'Diavola',
              overrides: {
                'image': {
                  'url': 'https://cdn.test/b.webp',
                  'alt': 'B',
                  'isPrimary': true,
                },
              },
            ),
          ],
        },
      ),
    });

    final categories = await repository.fetchCategories();
    final products = await repository.fetchProducts();

    expect(categories.single.name, 'Pizzas');
    expect(products.map((p) => p.image?.url), [
      'https://web.test/image/a.webp',
      'https://cdn.test/b.webp',
    ]);
  });

  test('traduce el error de la API a ServerException con su código', () async {
    final repository = repositoryWith({
      '/products': (
        status: 503,
        body: {
          'error': {
            'code': 'SERVICE_UNAVAILABLE',
            'message': 'Database down',
            'requestId': 'req-1',
          },
        },
      ),
    });

    await expectLater(
      repository.fetchProducts(),
      throwsA(
        isA<ServerException>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.code, 'code', 'SERVICE_UNAVAILABLE')
            .having((e) => e.requestId, 'requestId', 'req-1'),
      ),
    );
  });

  test('sin conexión lanza NetworkException', () async {
    final repository = repositoryWith({});

    await expectLater(
      repository.fetchCategories(),
      throwsA(isA<NetworkException>()),
    );
  });

  test('una respuesta sin "data" es UnexpectedResponseException', () async {
    final repository = repositoryWith({
      '/categories': (status: 200, body: {'otra': 1}),
    });

    await expectLater(
      repository.fetchCategories(),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });
}
