import 'package:fornea/core/network/api_exception.dart';

/// Perfil del cliente (`GET /me`, exige sesión). Solo los campos que muestra la app; el resto
/// (roles, permisos…) se ignora.
class Profile {
  const Profile({
    required this.email,
    required this.fullName,
    required this.username,
    required this.createdAt,
  });

  factory Profile.fromJson(Object? json) => switch (json) {
    {
      'email': final String email,
      'fullName': final String fullName,
      'username': final String? username,
      'createdAt': final String createdAt,
    } =>
      Profile(
        email: email,
        fullName: fullName,
        username: username,
        createdAt: DateTime.parse(createdAt),
      ),
    _ => throw const UnexpectedResponseException('Perfil no válido'),
  };

  final String email;
  final String fullName;
  final String? username;
  final DateTime createdAt;

  /// Como en la web: el nombre de usuario si lo tiene; si no, el nombre completo.
  String get displayName => username ?? fullName;
}
