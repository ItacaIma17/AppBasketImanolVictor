// lib/models/entrenador/entrenador.dart
class Entrenador {
  final int? id;
  final String nombre;
  final String? apellido;
  final String nombreCompleto;
  final String username;
  final String email;
  final int edad;
  final String codigoEntrenador;
  final String? telefono;
  final String? experiencia;
  final bool verificado;
  final int? equipoId;
  final String? nombreEquipo;

  Entrenador({
    this.id,
    required this.nombre,
    this.apellido,
    required this.nombreCompleto,
    required this.username,
    required this.email,
    required this.edad,
    required this.codigoEntrenador,
    this.telefono,
    this.experiencia,
    required this.verificado,
    this.equipoId,
    this.nombreEquipo,
  });

  factory Entrenador.fromJson(Map<String, dynamic> json) {
    return Entrenador(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      nombreCompleto: json['nombreCompleto'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      edad: json['edad'] ?? 0,
      codigoEntrenador: json['codigoEntrenador'] ?? '',
      telefono: json['telefono'],
      experiencia: json['experiencia'],
      verificado: json['verificado'] ?? false,
      equipoId: json['equipoId'],
      nombreEquipo: json['nombreEquipo'],
    );
  }
}