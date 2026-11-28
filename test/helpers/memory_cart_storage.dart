import 'package:fornea/features/cart/data/cart_storage.dart';
import 'package:fornea/features/cart/domain/cart_line.dart';
import 'package:fornea/features/checkout/domain/quote.dart';

/// Carrito guardado en memoria en vez de en el dispositivo.
class MemoryCartStorage implements CartStorage {
  MemoryCartStorage([List<CartLine> initial = const []]) : saved = [...initial];

  /// Lo último que se guardó.
  List<CartLine> saved;

  @override
  Future<List<CartLine>> load() async => saved;

  @override
  Future<void> save(List<CartLine> lines) async => saved = [...lines];
}

/// Línea de carrito para las pruebas, con nombre «Producto [productId]».
CartLine cartLine(
  String productId, {
  List<String> options = const [],
  int quantity = 1,
  String? notes,
}) => CartLine(
  item: QuoteItem(
    productId: productId,
    optionIds: options,
    quantity: quantity,
    notes: notes,
  ),
  name: 'Producto $productId',
  imageUrl: null,
  imageAlt: '',
  optionSummary: '',
);
