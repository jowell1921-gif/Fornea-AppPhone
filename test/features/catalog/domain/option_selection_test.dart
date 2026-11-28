import 'package:flutter_test/flutter_test.dart';
import 'package:fornea/features/catalog/domain/option_selection.dart';
import 'package:fornea/features/catalog/domain/product.dart';

import '../../../helpers/fake_api.dart';

Product _pizza() => Product.fromJson(
  productJson(
    id: 'p1',
    categoryId: 'c1',
    overrides: {
      'optionGroups': [
        optionGroupJson(
          id: 'size',
          name: 'Tamaño',
          required: true,
          minSelect: 1,
          options: [
            optionJson(id: 'm', name: 'Mediana', isDefault: true),
            optionJson(id: 'f', name: 'Familiar', priceDelta: '4.00'),
          ],
        ),
        optionGroupJson(
          id: 'extras',
          name: 'Extras',
          maxSelect: 2,
          options: [
            optionJson(id: 'a', name: 'Albahaca'),
            optionJson(id: 'b', name: 'Burrata'),
            optionJson(id: 'c', name: 'Champiñón'),
            optionJson(
              id: 'x',
              name: 'Agotada',
              isDefault: true,
              available: false,
            ),
          ],
        ),
      ],
    },
  ),
  resolveUrl: (url) => url,
);

void main() {
  final pizza = _pizza();
  final size = pizza.optionGroups[0];
  final extras = pizza.optionGroups[1];

  test('empieza con las opciones por defecto disponibles', () {
    final selection = OptionSelection.defaults(pizza);

    expect(selection.optionIds, ['m']);
    expect(selection.isCompleteFor(pizza), isTrue);
  });

  test('en un grupo de opción única, elegir otra la sustituye', () {
    final selection = OptionSelection.defaults(pizza)
        .toggle(size, size.options[1]);

    expect(selection.optionIds, ['f']);
  });

  test('no deja pasar del máximo y permite desmarcar', () {
    var selection = OptionSelection.defaults(pizza)
        .toggle(extras, extras.options[0])
        .toggle(extras, extras.options[1]);
    expect(selection.isFull(extras), isTrue);

    selection = selection.toggle(extras, extras.options[2]);
    expect(selection.optionIds, ['m', 'a', 'b']);

    selection = selection.toggle(extras, extras.options[0]);
    expect(selection.optionIds, ['m', 'b']);
    expect(selection.isFull(extras), isFalse);
  });

  test('un grupo obligatorio vacío deja la selección incompleta', () {
    final noDefaults = Product.fromJson(
      productJson(
        id: 'p2',
        categoryId: 'c1',
        overrides: {
          'optionGroups': [
            optionGroupJson(
              id: 'size',
              name: 'Tamaño',
              required: true,
              options: [optionJson(id: 'm', name: 'Mediana')],
            ),
          ],
        },
      ),
      resolveUrl: (url) => url,
    );

    expect(
      OptionSelection.defaults(noDefaults).isCompleteFor(noDefaults),
      isFalse,
    );
  });
}
