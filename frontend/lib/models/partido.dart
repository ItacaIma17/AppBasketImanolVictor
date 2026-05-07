class Partido {
  final int id;
  final int idLocal;
  final int idVisitante;
  final String nombreLocal;
  final String nombreVisitante;
  final int puntosLocal;
  final int puntosVisitante;
  final String fecha;
  final String hora;
  final String pabellon;
  final String direccionPabellon;
  final String ligaId;
  final String arbitroId;
  final String estado;
  final String actaUrl;
  final String observaciones;
  final String fechaCreacion;
  final String fechaActualizacion;
  final bool? tieneActa;
  final int? actaId;
  final bool? tieneAlineacionLocal;
  final bool? tieneAlineacionVisitante;
  final int? alineacionLocalId;
  final int? alineacionVisitanteId;
  final int? jornada;

  Partido({
    required this.id,
    required this.idLocal,
    required this.idVisitante,
    required this.nombreLocal,
    required this.nombreVisitante,
    required this.puntosLocal,
    required this.puntosVisitante,
    required this.fecha,
    required this.hora,
    required this.pabellon,
    required this.direccionPabellon,
    required this.ligaId,
    required this.arbitroId,
    required this.estado,
    required this.actaUrl,
    required this.observaciones,
    required this.fechaCreacion,
    required this.fechaActualizacion,

    // Extra
    this.tieneActa,
    this.actaId,
    this.tieneAlineacionLocal,
    this.tieneAlineacionVisitante,
    this.alineacionLocalId,
    this.alineacionVisitanteId,
    this.jornada,
  });

  factory Partido.fromJson(dynamic json) {
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

    return Partido(
      id: _parseInt(json['id']),
      idLocal: _parseInt(json['equipo_local_id'] ?? json['idLocal']),
      idVisitante: _parseInt(json['equipo_visitante_id'] ?? json['idVisitante']),
      nombreLocal: json['nombreLocal'] ?? '',
      nombreVisitante: json['nombreVisitante'] ?? '',
      puntosLocal: _parseInt(json['marcador_local'] ?? json['puntosLocal']),
      puntosVisitante: _parseInt(json['marcador_visitante'] ?? json['puntosVisitante']),
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      pabellon: json['pabellon'] ?? '',
      direccionPabellon: json['direccion_pabellon'] ?? '',
      ligaId: (json['liga_id'] ?? '').toString(),
      arbitroId: (json['arbitro_id'] ?? '').toString(),
      estado: json['estado'] ?? 'PROGRAMADO',
      actaUrl: json['acta_url'] ?? '',
      observaciones: json['observaciones'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
      fechaActualizacion: json['fecha_actualizacion'] ?? '',
      // Extra
      tieneActa: json['tieneActa'],
      actaId: _parseIntNullable(json['actaId']),
      tieneAlineacionLocal: json['tieneAlineacionLocal'],
      tieneAlineacionVisitante: json['tieneAlineacionVisitante'],
      alineacionLocalId: _parseIntNullable(json['alineacionLocalId']),
      alineacionVisitanteId: _parseIntNullable(json['alineacionVisitanteId']),
      jornada: _parseIntNullable(json['jornada']),
    );
  }

  String get resultado => "$puntosLocal - $puntosVisitante";

  bool get estaProgramado => estado == "PROGRAMADO";
  bool get estaFinalizado => estado == "FINALIZADO";
  bool get estaEnCurso => estado == "EN_CURSO";
}
