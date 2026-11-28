import 'package:fornea/core/network/api_exception.dart';

/// Estados del pedido. La app solo los muestra: las transiciones las decide el servidor.
enum OrderStatus {
  pendingPayment('Pendiente de pago'),
  received('Recibido'),
  accepted('Aceptado'),
  preparing('En preparación'),
  ready('Listo'),
  outForDelivery('En reparto'),
  completed('Completado'),
  rejected('Rechazado'),
  cancelled('Cancelado'),

  /// Un estado que esta versión de la app aún no conoce.
  unknown('En curso');

  const OrderStatus(this.label);

  /// Texto para el cliente, el mismo que la web.
  final String label;

  /// El pedido ya no va a cambiar.
  bool get isFinished =>
      this == completed || this == rejected || this == cancelled;

  static OrderStatus fromJson(String value) => switch (value) {
    'PENDING_PAYMENT' => pendingPayment,
    'NEW' => received,
    'ACCEPTED' => accepted,
    'PREPARING' => preparing,
    'READY' => ready,
    'OUT_FOR_DELIVERY' => outForDelivery,
    'COMPLETED' => completed,
    'REJECTED' => rejected,
    'CANCELLED' => cancelled,
    _ => unknown,
  };
}

enum OrderType {
  pickup('Recogida'),
  delivery('A domicilio'),
  unknown('Pedido');

  const OrderType(this.label);

  final String label;

  static OrderType fromJson(String value) => switch (value) {
    'PICKUP' => pickup,
    'DELIVERY' => delivery,
    _ => unknown,
  };
}

/// Resumen de un pedido del cliente (`GET /orders/me`, exige sesión).
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.type,
    required this.total,
    required this.itemCount,
    required this.createdAt,
  });

  factory OrderSummary.fromJson(Object? json) => switch (json) {
    {
      'id': final String id,
      'orderNumber': final int orderNumber,
      'status': final String status,
      'type': final String type,
      'total': final String total,
      'itemCount': final int itemCount,
      'createdAt': final String createdAt,
    } =>
      OrderSummary(
        id: id,
        orderNumber: orderNumber,
        status: OrderStatus.fromJson(status),
        type: OrderType.fromJson(type),
        total: total,
        itemCount: itemCount,
        createdAt: DateTime.parse(createdAt),
      ),
    _ => throw const UnexpectedResponseException('Pedido no válido'),
  };

  final String id;
  final int orderNumber;
  final OrderStatus status;
  final OrderType type;

  /// Importe cobrado, tal como lo guarda el servidor (`"27.00"`).
  final String total;
  final int itemCount;
  final DateTime createdAt;
}
