// lib/models/partido.dart
import 'package:flutter/material.dart';

class Partido {
  final int? id;
  final int? equipoLocalId;
  final String equipoLocal;
  final int? equipoVisitanteId;
  final String equipoVisitante;
  final int? arbitroId;
  final String? arbitroNombre;
  final DateTime fecha;
  final String? ubicacion;
  final int? resultadoLocal;
  final int? resultadoVisitante;
  final String estado;
  final bool? tieneActa;
  final int? actaId;
  final bool? tieneAlineacionLocal;
  final bool? tieneAlineacionVisitante;
  final int? alineacionLocalId;
  final int? alineacionVisitanteId;

  Partido({
    this.id,
    this.equipoLocalId,
    required this.equipoLocal,
    this.equipoVisitanteId,
    required this.equipoVisitante,
    this.arbitroId,
    this.arbitroNombre,
    required this.fecha,
    this.ubicacion,
    this.resultadoLocal,
    this.resultadoVisitante,
    required this.estado,
    this.tieneActa,
    this.actaId,
    this.tieneAlineacionLocal,
    this.tieneAlineacionVisitante,
    this.alineacionLocalId,
    this.alineacionVisitanteId,
  });

  factory Partido.fromJson(Map<String, dynamic> json) {
    return Partido(
      id: json['id'],
      equipoLocalId: json['equipoLocalId'],
      equipoLocal: json['equipoLocal'] ?? '',
      equipoVisitanteId: json['equipoVisitanteId'],
      equipoVisitante: json['equipoVisitante'] ?? '',
      arbitroId: json['arbitroId'],
      arbitroNombre: json['arbitroNombre'],
      fecha: DateTime.parse(json['fecha']),
      ubicacion: json['ubicacion'],
      resultadoLocal: json['resultadoLocal'],
      resultadoVisitante: json['resultadoVisitante'],
      estado: json['estado'] ?? 'PROGRAMADO',
      tieneActa: json['tieneActa'] ?? false,
      actaId: json['actaId'],
      tieneAlineacionLocal: json['tieneAlineacionLocal'] ?? false,
      tieneAlineacionVisitante: json['tieneAlineacionVisitante'] ?? false,
      alineacionLocalId: json['alineacionLocalId'],
      alineacionVisitanteId: json['alineacionVisitanteId'],
    );
  }

  bool get estaFinalizado => estado == 'FINALIZADO';
  bool get estaProgramado => estado == 'PROGRAMADO';
  bool get estaEnCurso => estado == 'EN_CURSO';

  String get resultado => '${resultadoLocal ?? 0} - ${resultadoVisitante ?? 0}';

  String get fechaFormateada {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}