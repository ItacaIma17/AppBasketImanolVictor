// lib/models/equipo/equipo.dart
class Equipo {
  final int? id;
  final id_liga;
  final String nombre;
  final String nombreEstadio;
  final String ciudad;
  final int anoFundacion;
  final String? escudoUrl;
  final int? ligaId;
  final String? nombreLiga;
  final int? entrenadorId;
  final String? nombreEntrenador;
  final int numeroJugadores;
  final double puntosFavor;
  final double puntosContra;
  final int victorias;
  final int derrotas;


  Equipo({
    this.id,
    this.id_liga,
    required this.nombre,
    required this.nombreEstadio,
    required this.ciudad,
    required this.anoFundacion,
    this.escudoUrl,
    this.ligaId,
    this.nombreLiga,
    this.entrenadorId,
    this.nombreEntrenador,
    this.numeroJugadores = 0,
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

      nombreEstadio: json['nombreEstadio'] ?? '',
      ciudad: json['ciudad'] ?? '',
      anoFundacion: json['añoFundacion'] ?? 0,
      escudoUrl: json['escudoUrl'],
      ligaId: json['ligaId'],
      nombreLiga: json['nombreLiga'],
      entrenadorId: json['entrenadorId'],
      nombreEntrenador: json['nombreEntrenador'],
      numeroJugadores: json['numeroJugadores'] ?? 0,
      puntosFavor: json['puntos'] ?? 0,
      puntosContra: json['puntosContra'] ?? 0,
      victorias: json['victorias'] ?? 0,
      derrotas: json['derrotas'] ?? 0,
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