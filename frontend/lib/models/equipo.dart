// lib/models/equipo/equipo.dart
class Equipo {
  final int? id;
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
  final double puntos;
  final int victorias;
  final int derrotas;


  Equipo({
    this.id,
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
    this.puntos = 0,
    this.victorias = 0,
    this.derrotas = 0,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'],
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
      puntos: json['puntos'] ?? 0,
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
      'puntos': puntos,
      'victorias': victorias,
      'derrotas': derrotas,
    };
  }
}