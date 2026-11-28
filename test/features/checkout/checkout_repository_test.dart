import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/core/network/api_client.dart';
import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/features/checkout/data/checkout_repository.dart';
import 'package:fornea/features/checkout/domain/line_quote.dart';

import '../../helpers/fake_api.dart';

void main() {
  test(
    'envía solo ids y cantidad, y lee el precio que calcula el servidor',
    () async {
      final adapter = FakeHttpAdapter({
        '/checkout/quote': (
          status: 200,
          body: quoteJson(unitPrice: '13.50', lineTotal: '27.00'),
        ),
      });
      final repository = CheckoutRepository(ApiClient(fakeDio(adapter)));

      final quote = await repository.quoteLine(
        LineQuoteRequest(
          productId: 'p1',
          optionIds: const ['b', 'a'],
          quantity: 2,
        ),
      );

      expect(quote.unitPrice, '13.50');
      expect(quote.lineTotal, '27.00');
      expect(adapter.bodies.single, {
        'items': [
          {
            'productId': 'p1',
            'quantity': 2,
            'optionIds': ['a', 'b'],
          },
        ],
        'type': 'PICKUP',
      });
    },
  );

  test(
    'una selección inválida llega como ServerException 422 con su código',
    () async {
      final adapter = FakeHttpAdapter({
        '/checkout/quote': (
          status: 422,
          body: {
            'error': {
              'code': 'INVALID_OPTIONS',
              'message': 'Invalid selection',
            },
          },
        ),
      });
      final repository = CheckoutRepository(ApiClient(fakeDio(adapter)));

      expect(
        repository.quoteLine(
          LineQuoteRequest(productId: 'p1', optionIds: const [], quantity: 1),
        ),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.code, 'code', 'INVALID_OPTIONS'),
        ),
      );
    },
  );

  test('dos peticiones con las mismas opciones en otro orden son iguales', () {
    expect(
      LineQuoteRequest(
        productId: 'p1',
        optionIds: const ['a', 'b'],
        quantity: 1,
      ),
      LineQuoteRequest(
        productId: 'p1',
        optionIds: const ['b', 'a'],
        quantity: 1,
      ),
    );
  });
}
