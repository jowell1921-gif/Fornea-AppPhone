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

/// Respuesta de `POST /checkout/quote` (cuerpo completo con `data`).
Map<String, Object?> quoteJson({
  required List<Map<String, Object?>> lines,
  required String total,
  List<Map<String, Object?>> discounts = const [],
}) => {
  'data': {
    'type': 'PICKUP',
    'lines': lines,
    'discounts': discounts,
    'totals': {
      'subtotal': total,
      'discount': '0.00',
      'deliveryFee': '0.00',
      'tax': '0.00',
      'total': total,
    },
    'delivery': null,
    'estimatedMinutes': 20,
    'pointsToEarn': 0,
  },
};

/// Una línea del presupuesto, tal como la devuelve el servidor.
Map<String, Object?> quoteLineJson({
  required String productId,
  required String lineTotal,
  List<String> optionIds = const [],
  int quantity = 1,
  String? notes,
}) => {
  'productId': productId,
  'productName': 'Producto $productId',
  'quantity': quantity,
  'notes': notes,
  'unitPrice': lineTotal,
  'lineTotal': lineTotal,
  'options': [
    for (final id in optionIds)
      {
        'optionId': id,
        'group': 'Grupo',
        'name': 'Opción $id',
        'priceDelta': '0.00',
      },
  ],
};
