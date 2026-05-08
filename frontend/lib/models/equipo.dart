// lib/models/equipo.dart
import 'jugador.dart';

class Equipo {
  final int? id;
  final String nombre;
  final String ciudad;
  final String nombreEstadio;
  final int? anoFundacion;
  final String? escudoUrl;
  final String? nombreLiga;
  final int? ligaId;
  final String? nombreEntrenador;
  final int? entrenadorId;
  final bool tieneEntrenador;
  final String? codigoSolicitud;
  final bool solicitudPendiente;
  final int? numeroJugadores;
  final List<Jugador>? jugadores;

  // Estadísticas de clasificación
  final int? puntos;
  final int? partidosJugados;
  final int? partidosGanados;
  final int? partidosPerdidos;

  Equipo({
    this.id,
    required this.nombre,
    required this.ciudad,
    required this.nombreEstadio,
    this.anoFundacion,
    this.escudoUrl,
    this.nombreLiga,
    this.ligaId,
    this.nombreEntrenador,
    this.entrenadorId,
    this.tieneEntrenador = false,
    this.codigoSolicitud,
    this.solicitudPendiente = false,
    this.numeroJugadores,
    this.jugadores,
    this.puntos,
    this.partidosJugados,
    this.partidosGanados,
    this.partidosPerdidos,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      ciudad: json['ciudad'] ?? '',
      nombreEstadio: json['nombreEstadio'] ?? '',
      anoFundacion: json['anoFundacion'] ?? json['añoFundacion'],
      escudoUrl: json['escudoUrl'],
      nombreLiga: json['nombreLiga'],
      ligaId: json['ligaId'],
      nombreEntrenador: json['nombreEntrenador'],
      entrenadorId: json['entrenadorId'],
      tieneEntrenador: json['tieneEntrenador'] ?? false,
      codigoSolicitud: json['codigoSolicitud'],
      solicitudPendiente: json['solicitudPendiente'] ?? false,
      numeroJugadores: json['numeroJugadores'],
      jugadores: json['jugadores'] != null
          ? (json['jugadores'] as List).map((j) => Jugador.fromJson(j)).toList()
          : [],
      puntos: json['puntos'],
      partidosJugados: json['partidosJugados'],
      partidosGanados: json['partidosGanados'],
      partidosPerdidos: json['partidosPerdidos'],
    );
  }
}