// lib/models/equipo_entrenador.dart
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
    this.jugadores,
  });

  factory EquipoEntrenador.fromJson(Map<String, dynamic> json) {
    return EquipoEntrenador(
      entrenadorId: json['entrenadorId'],
      nombreEntrenador: json['nombreEntrenador'],
      apellido: json['apellido'],
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      equipoId: json['equipoId'],
      nombreEquipo: json['nombreEquipo'] ?? '',
      nombreLiga: json['nombreLiga'],
      nombreEstadio: json['nombreEstadio'],
      tieneEquipo: json['tieneEquipo'] ?? false,
      numeroJugadores: json['numeroJugadores'],
      jugadores: json['jugadores'] != null
          ? (json['jugadores'] as List)
          .map((j) => Jugador.fromJson(j))
          .toList()
          : [],
    );
  }

  String get nombreCompletoEntrenador => '$nombreEntrenador ${apellido ?? ''}'.trim();
}