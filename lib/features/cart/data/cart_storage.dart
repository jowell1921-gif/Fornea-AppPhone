import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/network/api_exception.dart';
import 'package:fornea/core/network/json_parsing.dart';
import 'package:fornea/features/cart/domain/cart_line.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dónde se guarda el carrito. Se sustituye por uno en memoria en las pruebas.
final cartStorageProvider = Provider<CartStorage>(
  (ref) => PreferencesCartStorage(SharedPreferencesAsync()),
);

/// Guarda el carrito en el dispositivo para recuperarlo al volver a abrir la app.
abstract interface class CartStorage {
  Future<List<CartLine>> load();
  Future<void> save(List<CartLine> lines);
}

/// [CartStorage] sobre `shared_preferences` (en Android, el `SharedPreferences` de siempre).
///
/// El carrito no tiene datos sensibles (ni precios ni datos personales), así que no necesita
/// almacenamiento cifrado.
class PreferencesCartStorage implements CartStorage {
  const PreferencesCartStorage(this._preferences);

  /// La versión va en la clave: si el formato cambia, se usa otra clave y el carrito antiguo
  /// se ignora en vez de leerse mal.
  static const String _key = 'fornea-cart-v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<CartLine>> load() async {
    final stored = await _preferences.getString(_key);
    if (stored == null) return const [];
    try {
      return parseList(jsonDecode(stored), CartLine.fromJson);
    } on FormatException {
      // Datos dañados: mejor empezar con el carrito vacío que bloquear la app.
      return const [];
    } on UnexpectedResponseException {
      return const [];
    }
  }

  @override
  Future<void> save(List<CartLine> lines) => _preferences.setString(
    _key,
    jsonEncode([for (final line in lines) line.toJson()]),
  );
}
