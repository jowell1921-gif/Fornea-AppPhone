import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Respuesta simulada: código HTTP y cuerpo JSON. `null` en [body] simula un fallo de red.
typedef FakeResponse = ({int status, Object? body});

/// Sustituye la red de Dio en las pruebas: responde según la ruta pedida, sin servidor real.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.routes);

  /// Ruta (`/products`) → respuesta. Se puede cambiar durante la prueba.
  final Map<String, FakeResponse> routes;

  /// Rutas pedidas, en orden, para comprobar cuántas llamadas se hicieron.
  final List<String> requests = [];

  /// Cuerpos enviados (en los `POST`), en el mismo orden que [requests].
  final List<Object?> bodies = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.path);
    bodies.add(options.data);
    final route = routes[options.path];
    if (route == null || route.body == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Sin conexión (simulada)',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(route.body),
      route.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Dio con la red simulada.
Dio fakeDio(FakeHttpAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
      ..httpClientAdapter = adapter;

/// Producto mínimo válido según el contrato; [overrides] cambia campos concretos.
Map<String, Object?> productJson({
  required String id,
  required String categoryId,
  String name = 'Margherita',
  Map<String, Object?> overrides = const {},
}) => {
  'id': id,
  'slug': name.toLowerCase(),
  'categoryId': categoryId,
  'categorySlug': 'pizzas',
  'name': name,
  'description': 'La clásica.',
  'price': '9.50',
  'taxRate': '10.00',
  'vegetarian': true,
  'available': true,
  'popular': true,
  'image': null,
  'images': <Object?>[],
  'ingredients': ['Tomate', 'Mozzarella'],
  'allergens': [
    {'code': 'gluten', 'name': 'Gluten'},
  ],
  'optionGroups': <Object?>[],
  ...overrides,
};

Map<String, Object?> categoryJson({required String id, required String name}) =>
    {'id': id, 'slug': name.toLowerCase(), 'name': name, 'description': null};

/// Grupo de opciones según el contrato; las opciones se crean con [optionJson].
Map<String, Object?> optionGroupJson({
  required String id,
  required String name,
  required List<Map<String, Object?>> options,
  bool required = false,
  int minSelect = 0,
  int maxSelect = 1,
}) => {
  'id': id,
  'name': name,
  'kind': 'EXTRA',
  'required': required,
  'minSelect': minSelect,
  'maxSelect': maxSelect,
  'options': options,
};

Map<String, Object?> optionJson({
  required String id,
  required String name,
  String priceDelta = '0.00',
  bool isDefault = false,
  bool available = true,
}) => {
  'id': id,
  'name': name,
  'priceDelta': priceDelta,
  'isDefault': isDefault,
  'available': available,
};

/// Respuesta de `POST /checkout/quote` con una sola línea (solo los campos que lee la app,
/// más alguno de los que ignora).
Map<String, Object?> quoteJson({
  required String unitPrice,
  required String lineTotal,
}) => {
  'data': {
    'type': 'PICKUP',
    'lines': [
      {
        'productId': 'p1',
        'productName': 'Margherita',
        'quantity': 1,
        'notes': null,
        'unitPrice': unitPrice,
        'lineTotal': lineTotal,
        'options': <Object?>[],
      },
    ],
    'totals': {'total': lineTotal},
  },
};
