class LoginResponse {
  final String token;
  final String refreshToken;
  final String username;
  final String nombre;
  final String? apellido;
  final String email;
  final String rol;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.username,
    required this.nombre,
    this.apellido,
    required this.email,
    required this.rol,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      email: json['email'] ?? '',
      rol: json['rol'] ?? '',
    );
  }
}
