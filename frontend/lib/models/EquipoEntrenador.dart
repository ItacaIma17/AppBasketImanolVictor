import 'jugador.dart';

class EquipoEntrenador {
  final int entrenadorId;
  final String nombreEntrenador;
  final String? apellido;
  final String email;
  final String username;
  final int equipoId;
  final String nombreEquipo;
  final String? nombreLiga;
  final String? nombreEstadio;
  final bool tieneEquipo;
  final int? numeroJugadores;
  final int? victorias;
  final List<Jugador>? jugadores;

  EquipoEntrenador({
    required this.entrenadorId,
    required this.nombreEntrenador,
    this.apellido,
    required this.email,
    required this.username,
    required this.equipoId,
    required this.nombreEquipo,
    this.nombreLiga,
    this.nombreEstadio,
    required this.tieneEquipo,
    this.numeroJugadores,
    this.victorias,
    this.jugadores,
  });

  factory EquipoEntrenador.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? _parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return EquipoEntrenador(
      entrenadorId: _parseInt(json['entrenadorId']),
      nombreEntrenador: json['nombreEntrenador'] ?? '',
      apellido: json['apellido'],
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      equipoId: _parseInt(json['equipoId']),
      nombreEquipo: json['nombreEquipo'] ?? '',
      nombreLiga: json['nombreLiga'],
      nombreEstadio: json['nombreEstadio'],
      tieneEquipo: json['tieneEquipo'] ?? false,
      numeroJugadores: _parseIntNullable(json['numeroJugadores']),
      victorias: _parseIntNullable(json['victorias']),
      jugadores: json['jugadores'] != null
          ? (json['jugadores'] as List)
          .map((j) => Jugador.fromJson(j))
          .toList()
          : [],
    );
  }

  String get nombreCompletoEntrenador => '$nombreEntrenador ${apellido ?? ''}'.trim();
}
