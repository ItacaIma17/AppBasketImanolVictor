class Partido {
  final String id;
  final String idLocal;
  final String idVisitante;
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
  });

  factory Partido.fromJson(dynamic json) {
    return Partido(
      id: (json['id'] ?? '').toString(),

      idLocal: (json['equipo_local_id'] ?? json['idLocal'] ?? '').toString(),
      idVisitante: (json['equipo_visitante_id'] ?? json['idVisitante'] ?? '').toString(),

      nombreLocal: json['nombreLocal'] ?? '',
      nombreVisitante: json['nombreVisitante'] ?? '',

      puntosLocal: json['marcador_local'] ?? json['puntosLocal'] ?? 0,
      puntosVisitante: json['marcador_visitante'] ?? json['puntosVisitante'] ?? 0,

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
      actaId: json['actaId'],
      tieneAlineacionLocal: json['tieneAlineacionLocal'],
      tieneAlineacionVisitante: json['tieneAlineacionVisitante'],
      alineacionLocalId: json['alineacionLocalId'],
      alineacionVisitanteId: json['alineacionVisitanteId'],
    );
  }

  String get resultado => "$puntosLocal - $puntosVisitante";

  bool get estaProgramado => estado == "PROGRAMADO";
  bool get estaFinalizado => estado == "FINALIZADO";
  bool get estaEnCurso => estado == "EN_CURSO";
}
