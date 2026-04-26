
import 'JugadorAlineacion.dart';

class Alineacion {
  final int? id;
  final int partidoId;
  final String equipoLocal;
  final String equipoVisitante;
  final int equipoId;
  final String nombreEquipo;
  final int? entrenadorId;
  final String nombreEntrenador;
  final DateTime fechaPresentacion;
  final bool confirmada;
  final List<JugadorAlineacion> titulares;
  final List<JugadorAlineacion> suplentes;

  Alineacion({
    this.id,
    required this.partidoId,
    required this.equipoLocal,
    required this.equipoVisitante,
    required this.equipoId,
    required this.nombreEquipo,
    this.entrenadorId,
    required this.nombreEntrenador,
    required this.fechaPresentacion,
    required this.confirmada,
    required this.titulares,
    required this.suplentes,
  });

  factory Alineacion.fromJson(Map<String, dynamic> json) {
    return Alineacion(
      id: json['id'],
      partidoId: json['partidoId'],
      equipoLocal: json['equipoLocal'],
      equipoVisitante: json['equipoVisitante'],
      equipoId: json['equipoId'],
      nombreEquipo: json['nombreEquipo'],
      entrenadorId: json['entrenadorId'],
      nombreEntrenador: json['nombreEntrenador'],
      fechaPresentacion: DateTime.parse(json['fechaPresentacion']),
      confirmada: json['confirmada'],
      titulares: (json['titulares'] as List)
          .map((e) => JugadorAlineacion.fromJson(e))
          .toList(),
      suplentes: (json['suplentes'] as List)
          .map((e) => JugadorAlineacion.fromJson(e))
          .toList(),
    );
  }
}