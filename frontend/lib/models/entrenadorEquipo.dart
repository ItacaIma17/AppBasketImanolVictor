// lib/models/entrenador/entrenador_equipo.dart
class EntrenadorEquipo {
  final int? entrenadorId;
  final String nombreEntrenador;
  final String? apellido;
  final String email;
  final String username;
  final int? equipoId;
  final String nombreEquipo;
  final String nombreLiga;
  final String nombreEstadio;
  final bool tieneEquipo;

  EntrenadorEquipo({
    this.entrenadorId,
    required this.nombreEntrenador,
    this.apellido,
    required this.email,
    required this.username,
    this.equipoId,
    required this.nombreEquipo,
    required this.nombreLiga,
    required this.nombreEstadio,
    required this.tieneEquipo,
  });

  factory EntrenadorEquipo.fromJson(Map<String, dynamic> json) {
    return EntrenadorEquipo(
      entrenadorId: json['entrenadorId'],
      nombreEntrenador: json['nombreEntrenador'] ?? '',
      apellido: json['apellido'],
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      equipoId: json['equipoId'],
      nombreEquipo: json['nombreEquipo'] ?? 'Sin equipo',
      nombreLiga: json['nombreLiga'] ?? 'Sin liga',
      nombreEstadio: json['nombreEstadio'] ?? 'Sin estadio',
      tieneEquipo: json['tieneEquipo'] ?? false,
    );
  }

  String get nombreCompletoEntrenador {
    if (apellido != null && apellido!.isNotEmpty) {
      return '$nombreEntrenador $apellido';
    }
    return nombreEntrenador;
  }
}