
import '../../role.dart';

class UsuarioPerfilDTO {
  final int id;
  final String email;
  final String username;
  final String nombre;
  final String? apellido;
  final int edad;
  final Role role;
  final bool verificado;
  final bool bloqueado;
  final List<String> equiposSiguiendo;
  final List<String> jugadoresSiguiendo;

  UsuarioPerfilDTO({
    required this.id,
    required this.email,
    required this.username,
    required this.nombre,
    this.apellido,
    required this.edad,
    required this.role,
    required this.verificado,
    required this.bloqueado,
    this.equiposSiguiendo = const [],
    this.jugadoresSiguiendo = const [],
  });

  factory UsuarioPerfilDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioPerfilDTO(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      edad: json['edad'] ?? 0,
      role: Role.fromString(json['role'] ?? 'USUARIO'),
      verificado: json['verificado'] ?? false,
      bloqueado: json['bloqueado'] ?? false,
      equiposSiguiendo: (json['equiposSiguiendo'] as List?)?.cast<String>() ?? [],
      jugadoresSiguiendo: (json['jugadoresSiguiendo'] as List?)?.cast<String>() ?? [],
    );
  }
}