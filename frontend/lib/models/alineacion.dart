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

  static int _toInt(dynamic v, {int defaultValue = 0}) {
    if (v == null) return defaultValue;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory Alineacion.fromJson(Map<String, dynamic> json) {
    final fechaRaw = json['fechaPresentacion'];
    DateTime fecha;
    if (fechaRaw is String && fechaRaw.isNotEmpty) {
      fecha = DateTime.tryParse(fechaRaw) ?? DateTime.now();
    } else {
      fecha = DateTime.now();
    }

    final titularesRaw = (json['titulares'] as List?) ?? const [];
    final suplentesRaw = (json['suplentes'] as List?) ?? const [];

    return Alineacion(
      id: _toIntOrNull(json['id']),
      partidoId: _toInt(json['partidoId']),
      equipoLocal: (json['equipoLocal'] ?? '').toString(),
      equipoVisitante: (json['equipoVisitante'] ?? '').toString(),
      equipoId: _toInt(json['equipoId']),
      nombreEquipo: (json['nombreEquipo'] ?? '').toString(),
      entrenadorId: _toIntOrNull(json['entrenadorId']),
      nombreEntrenador: (json['nombreEntrenador'] ?? '').toString(),
      fechaPresentacion: fecha,
      confirmada: json['confirmada'] == true,
      titulares: titularesRaw
          .whereType<Map>()
          .map((e) => JugadorAlineacion.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      suplentes: suplentesRaw
          .whereType<Map>()
          .map((e) => JugadorAlineacion.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
