// lib/models/equipo.dart
import 'jugador.dart';

class Equipo {
  final int? id;
  final int? id_liga;
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
  final double puntosFavor;
  final double puntosContra;
  final int victorias;
  final int derrotas;

  Equipo({
    this.id,
    this.id_liga,
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
    this.puntosFavor = 0,
    this.puntosContra = 0,
    this.victorias = 0,
    this.derrotas = 0,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'],
      id_liga: json['id_liga'],
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
      puntosFavor: json['puntos'] ?? 0,
      puntosContra: json['puntosContra'] ?? 0,
      victorias: json['victorias'] ?? 0,
      derrotas: json['derrotas'] ?? 0,
      jugadores: json['jugadores'] != null
          ? (json['jugadores'] as List)
          .map((j) => Jugador.fromJson(j))
          .toList()
          : [],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'nombreEstadio': nombreEstadio,
      'ciudad': ciudad,
      'añoFundacion': anoFundacion,
      'escudoUrl': escudoUrl,
      'ligaId': ligaId,
      'puntosFavor': puntosFavor,
      'puntosContra': puntosContra,
      'victorias': victorias,
      'derrotas': derrotas,
    };
  }
}