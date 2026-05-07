
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

    return Alineacion(
      id: _parseIntNullable(json['id']),
      partidoId: _parseInt(json['partidoId']),
      equipoLocal: json['equipoLocal'] ?? '',
      equipoVisitante: json['equipoVisitante'] ?? '',
      equipoId: _parseInt(json['equipoId']),
      nombreEquipo: json['nombreEquipo'] ?? '',
      entrenadorId: _parseIntNullable(json['entrenadorId']),
      nombreEntrenador: json['nombreEntrenador'] ?? '',
      fechaPresentacion: DateTime.parse(json['fechaPresentacion']),
      confirmada: json['confirmada'] ?? false,
      titulares: (json['titulares'] as List? ?? [])
          .map((e) => JugadorAlineacion.fromJson(e))
          .toList(),
      suplentes: (json['suplentes'] as List? ?? [])
          .map((e) => JugadorAlineacion.fromJson(e))
          .toList(),
    );
  }
}