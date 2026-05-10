class cambiarContrasenaResponse {
  final String email;
  final DateTime fechaActualizacion;

  cambiarContrasenaResponse({
    required this.email,
    required this.fechaActualizacion,
  });

  factory cambiarContrasenaResponse.fromJson(Map<String, dynamic> json) {
    return cambiarContrasenaResponse(
      email: json['email'] ?? '',
      fechaActualizacion: DateTime.parse(json['fechaActualizacion']),
    );
  }
}
