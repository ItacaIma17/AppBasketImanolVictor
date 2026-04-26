// lib/models/acta.dart
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
  });

  factory ActaPartido.fromJson(Map<String, dynamic> json) {
    return ActaPartido(
      id: json['id'],
      partidoId: json['partidoId'],
      equipoLocal: json['equipoLocal'],
      equipoVisitante: json['equipoVisitante'],
      resultadoLocal: json['resultadoLocal'],
      resultadoVisitante: json['resultadoVisitante'],
      arbitroId: json['arbitroId'],
      arbitroNombre: json['arbitroNombre'],
      fechaActa: DateTime.parse(json['fechaActa']),
      observaciones: json['observaciones'],
      eventos: (json['eventos'] as List)
          .map((e) => EventoActa.fromJson(e))
          .toList(),
      puedeEditar: json['puedeEditar'] ?? false,
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
    return EventoActa(
      id: json['id'],
      jugadorId: json['jugadorId'],
      nombreJugador: json['nombreJugador'],
      nombreEquipo: json['nombreEquipo'],
      minuto: json['minuto'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      puntos: json['puntos'],
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