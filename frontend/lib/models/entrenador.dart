// lib/models/entrenador.dart

class Entrenador {
  final int? id;
  final String nombre;
  final String? apellido;
  final String username;
  final String email;
  final int edad;
  final String codigoEntrenador;
  final String? telefono;
  final String? experiencia;
  final bool verificado;
  final bool tieneEquipo;
  final int? equipoId;
  final String? nombreEquipo;

  Entrenador({
    this.id,
    required this.nombre,
    this.apellido,
    required this.username,
    required this.email,
    required this.edad,
    required this.codigoEntrenador,
    this.telefono,
    this.experiencia,
    this.verificado = false,
    this.tieneEquipo = false,
    this.equipoId,
    this.nombreEquipo,
  });

  factory Entrenador.fromJson(Map<String, dynamic> json) {
    return Entrenador(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      edad: json['edad'] ?? 0,
      codigoEntrenador: json['codigoEntrenador'] ?? '',
      telefono: json['telefono'],
      experiencia: json['experiencia'],
      verificado: json['verificado'] ?? false,
      tieneEquipo: json['tieneEquipo'] ?? false,
      equipoId: json['equipoId'],
      nombreEquipo: json['nombreEquipo'],
    );
  }

  String get nombreCompleto => '$nombre ${apellido ?? ''}'.trim();
}