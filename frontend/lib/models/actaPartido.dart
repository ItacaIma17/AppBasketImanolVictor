class ActaPartido {
  final int? id;
  final int partidoId;
  final String equipoLocal;
  final String equipoVisitante;
  final String resultadoLocal;
  final String resultadoVisitante;
  final int? arbitroId;
  final String arbitroNombre;
  final DateTime fechaActa;
  final String? observaciones;
  final List<EventoActa> eventos;
  final bool puedeEditar;
  final bool tieneArchivoSubido;

  ActaPartido({
    this.id,
    required this.partidoId,
    required this.equipoLocal,
    required this.equipoVisitante,
    required this.resultadoLocal,
    required this.resultadoVisitante,
    this.arbitroId,
    required this.arbitroNombre,
    required this.fechaActa,
    this.observaciones,
    required this.eventos,
    this.puedeEditar = false,
    this.tieneArchivoSubido = false,
  });

  factory ActaPartido.fromJson(Map<String, dynamic> json) {
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

    return ActaPartido(
      id: _parseIntNullable(json['id']),
      partidoId: _parseInt(json['partidoId']),
      equipoLocal: json['equipoLocal'] ?? '',
      equipoVisitante: json['equipoVisitante'] ?? '',
      resultadoLocal: json['resultadoLocal'] ?? '',
      resultadoVisitante: json['resultadoVisitante'] ?? '',
      arbitroId: _parseIntNullable(json['arbitroId']),
      arbitroNombre: json['arbitroNombre'] ?? '',
      fechaActa: json['fechaActa'] != null
          ? DateTime.tryParse(json['fechaActa'].toString()) ?? DateTime.now()
          : DateTime.now(),
      observaciones: json['observaciones'],
      eventos: (json['eventos'] as List? ?? [])
          .map((e) => EventoActa.fromJson(e))
          .toList(),
      puedeEditar: json['puedeEditar'] ?? false,
      tieneArchivoSubido: json['tieneArchivoSubido'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partidoId': partidoId,
      'equipoLocal': equipoLocal,
      'equipoVisitante': equipoVisitante,
      'resultadoLocal': resultadoLocal,
      'resultadoVisitante': resultadoVisitante,
      'arbitroId': arbitroId,
      'arbitroNombre': arbitroNombre,
      'fechaActa': fechaActa.toIso8601String(),
      'observaciones': observaciones,
      'eventos': eventos.map((e) => e.toJson()).toList(),
      'puedeEditar': puedeEditar,
      'tieneArchivoSubido': tieneArchivoSubido,
    };
  }
}

class EventoActa {
  final int? id;
  final int? jugadorId;
  final String nombreJugador;
  final String nombreEquipo;
  final int minuto;
  final String tipo;
  final String? descripcion;
  final int? puntos;

  EventoActa({
    this.id,
    this.jugadorId,
    required this.nombreJugador,
    required this.nombreEquipo,
    required this.minuto,
    required this.tipo,
    this.descripcion,
    this.puntos,
  });

  factory EventoActa.fromJson(Map<String, dynamic> json) {
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

    return EventoActa(
      id: _parseIntNullable(json['id']),
      jugadorId: _parseIntNullable(json['jugadorId']),
      nombreJugador: json['nombreJugador'] ?? '',
      nombreEquipo: json['nombreEquipo'] ?? '',
      minuto: _parseInt(json['minuto']),
      tipo: json['tipo'] ?? '',
      descripcion: json['descripcion'],
      puntos: _parseIntNullable(json['puntos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jugadorId': jugadorId,
      'nombreJugador': nombreJugador,
      'nombreEquipo': nombreEquipo,
      'minuto': minuto,
      'tipo': tipo,
      'descripcion': descripcion,
      'puntos': puntos,
    };
  }
}
