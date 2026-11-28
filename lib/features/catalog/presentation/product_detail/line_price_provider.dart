import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/features/checkout/data/checkout_repository.dart';
import 'package:fornea/features/checkout/domain/line_quote.dart';

/// Precio de la configuración elegida en la ficha, calculado por el servidor.
///
/// Cada combinación (opciones + cantidad) es un provider distinto (`family`). Al cambiar algo,
/// el anterior deja de usarse y `autoDispose` lo descarta. La espera inicial evita una
/// petición por cada toque cuando el usuario cambia varias cosas seguidas: si en ese tiempo
/// el provider se descarta, no llega a pedir nada.
final linePriceProvider = FutureProvider.autoDispose
    .family<LineQuote, LineQuoteRequest>((ref, request) async {
      var disposed = false;
      ref.onDispose(() => disposed = true);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (disposed) throw const _Superseded();

      return ref.watch(checkoutRepositoryProvider).quoteLine(request);
    });

/// La petición se abandonó porque la selección cambió antes de enviarla. Nadie llega a verlo.
class _Superseded implements Exception {
  const _Superseded();
}
