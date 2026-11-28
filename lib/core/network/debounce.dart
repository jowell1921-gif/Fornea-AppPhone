import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Espera breve antes de una petición desde un provider.
///
/// Si en ese tiempo el provider se descarta o se reconstruye (porque el usuario cambió algo),
/// lanza [Superseded] y la petición no se hace: así no se envía una por cada toque.
Future<void> debounce(Ref ref) async {
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (disposed) throw const Superseded();
}

/// La petición se abandonó porque los datos cambiaron antes de enviarla. Nadie llega a verlo:
/// el provider ya se ha sustituido por otro.
class Superseded implements Exception {
  const Superseded();
}
