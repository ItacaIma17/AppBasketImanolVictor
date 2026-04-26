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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'username': username,
      'email': email,
      'edad': edad,
      'codigoEntrenador': codigoEntrenador,
      'telefono': telefono,
      'experiencia': experiencia,
      'verificado': verificado,
    };
  }
}