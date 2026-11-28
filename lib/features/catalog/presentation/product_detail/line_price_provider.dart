import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/debounce.dart';
import 'package:fornea/features/checkout/data/checkout_repository.dart';
import 'package:fornea/features/checkout/domain/quote.dart';

/// Precio de la configuración elegida en la ficha, calculado por el servidor.
///
/// Cada combinación (opciones + cantidad) es un provider distinto (`family`). Al cambiar algo,
/// el anterior deja de usarse y `autoDispose` lo descarta; [debounce] evita pedir precio en
/// cada toque.
final linePriceProvider = FutureProvider.autoDispose
    .family<QuoteLine, QuoteItem>((ref, item) async {
      await debounce(ref);
      final quote = await ref.watch(checkoutRepositoryProvider).quote([item]);
      return quote.lines.single;
    });
