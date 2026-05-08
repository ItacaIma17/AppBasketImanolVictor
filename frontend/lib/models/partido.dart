// lib/models/partido.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Partido {
  final int id;
  final int? equipoLocalId;
  final int? equipoVisitanteId;
  final String nombreLocal;
  final String nombreVisitante;
  final int puntosLocal;
  final int puntosVisitante;
  final String fecha;
  final String hora;
  final String pabellon;
  final String direccionPabellon;
  final int? ligaId;
  final int? arbitroId;
  final String? nombreArbitro;
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
    this.equipoLocalId,
    this.equipoVisitanteId,
    required this.nombreLocal,
    required this.nombreVisitante,
    required this.puntosLocal,
    required this.puntosVisitante,
    required this.fecha,
    required this.hora,
    required this.pabellon,
    required this.direccionPabellon,
    this.ligaId,
    this.arbitroId,
    required this.nombreArbitro,
    required this.estado,
    required this.actaUrl,
    required this.observaciones,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.tieneActa,
    this.actaId,
    this.tieneAlineacionLocal,
    this.tieneAlineacionVisitante,
    this.alineacionLocalId,
    this.alineacionVisitanteId,
    this.jornada,
  });

  // ============================================================
  // MÉTODOS AUXILIARES
  // ============================================================

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  static int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  // ============================================================
  // PARSEO DE FECHAS
  //
  // Acepta los siguientes formatos (con o sin hora):
  //   - "2026-04-23T14:00:00"      (ISO 8601)
  //   - "2026-04-23T14:00:00.123Z" (ISO con milis y zona)
  //   - "2026-04-23 14:00:00"      (ISO con espacio)
  //   - "23/04/2026"               (dd/MM/yyyy)
  //   - "23/04/2026 14:00"         (dd/MM/yyyy + hora opcional)
  //   - "23-04-2026"               (dd-MM-yyyy)
  // ============================================================

  /// API pública para parsear fechas desde cualquier widget.
  /// Devuelve `null` si el string no se puede parsear (en lugar de lanzar
  /// `FormatException`), evitando los crashes de `DateTime.parse`.
  static DateTime? parseFecha(String fechaStr) => _parseDateTime(fechaStr);

  static DateTime? _parseDateTime(String fechaStr) {
    if (fechaStr.isEmpty) return null;
    try {
      String clean = fechaStr.trim();

      // Quitar zona/sufijo Z (no soportado por DateTime.parse cuando es timezone con offset)
      if (clean.contains('+')) clean = clean.split('+').first;
      if (clean.endsWith('Z')) clean = clean.substring(0, clean.length - 1);

      // Recortar microsegundos por encima de los milisegundos
      if (clean.contains('.') && clean.contains('T')) {
        final parts = clean.split('.');
        if (parts.length >= 2) clean = parts[0];
      }

      // Formato dd/MM/yyyy (con o sin hora detrás separada por espacio)
      if (clean.contains('/') && !clean.contains('T')) {
        // Separar parte de fecha y parte de hora si existiese ("23/04/2026 14:00")
        String fechaPart = clean;
        String? horaPart;
        if (clean.contains(' ')) {
          final pieces = clean.split(RegExp(r'\s+'));
          fechaPart = pieces.first;
          if (pieces.length >= 2) horaPart = pieces[1];
        }
        final parts = fechaPart.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          int hour = 0, minute = 0, second = 0;
          if (horaPart != null) {
            final hParts = horaPart.split(':');
            if (hParts.isNotEmpty) hour = int.tryParse(hParts[0]) ?? 0;
            if (hParts.length > 1) minute = int.tryParse(hParts[1]) ?? 0;
            if (hParts.length > 2) second = int.tryParse(hParts[2]) ?? 0;
          }
          return DateTime(year, month, day, hour, minute, second);
        }
      }

      // Formato dd-MM-yyyy (sin la 'T' del ISO)
      if (clean.contains('-') && !clean.contains('T')) {
        final parts = clean.split(RegExp(r'[\s\-]'));
        // ISO yyyy-MM-dd: parts[0].length == 4 → dejar a DateTime.parse
        if (parts.length >= 3 && parts[0].length <= 2) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);
          if (day != null && month != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      }

      // ISO con espacio en lugar de T
      if (!clean.contains('T') && clean.contains(' ') &&
          RegExp(r'^\d{4}-').hasMatch(clean)) {
        clean = clean.replaceFirst(' ', 'T');
      }

      return DateTime.tryParse(clean);
    } catch (e) {
      print('Error parseando fecha "$fechaStr": $e');
      return null;
    }
  }

  static String _formatearFecha(dynamic fechaValue) {
    if (fechaValue == null) return '';
    final fechaStr = fechaValue.toString();
    final date = _parseDateTime(fechaStr);
    if (date != null) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return fechaStr;
  }

  static String _formatearHora(dynamic fechaValue) {
    if (fechaValue == null) return '';
    try {
      String fechaStr = fechaValue.toString();
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(fechaStr)) return fechaStr;
      final date = _parseDateTime(fechaStr);
      if (date != null) {
        final hour = date.hour.toString().padLeft(2, '0');
        final minute = date.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory Partido.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('📦 Parseando partido: ${json['id']}');
      print('   Local: ${json['nombreLocal']} vs Visitante: ${json['nombreVisitante']}');
    }

    String fechaRaw = '';
    if (json['fecha'] != null) {
      fechaRaw = json['fecha'].toString();
    } else if (json['fechaHora'] != null) {
      fechaRaw = json['fechaHora'].toString();
    } else if (json['fecha_partido'] != null) {
      fechaRaw = json['fecha_partido'].toString();
    }

    return Partido(
      id: _toInt(json['id']),
      equipoLocalId: _toIntOrNull(json['equipoLocalId'] ?? json['equipo_local_id']),
      equipoVisitanteId: _toIntOrNull(json['equipoVisitanteId'] ?? json['equipo_visitante_id']),
      nombreLocal: json['nombreLocal']?.toString() ??
          json['equipoLocal']?['nombre']?.toString() ??
          json['equipo_local_nombre']?.toString() ??
          'Local',
      nombreVisitante: json['nombreVisitante']?.toString() ??
          json['equipoVisitante']?['nombre']?.toString() ??
          json['equipo_visitante_nombre']?.toString() ??
          'Visitante',
      puntosLocal: _toInt(json['puntosLocal'] ?? json['resultadoLocal'] ?? 0),
      puntosVisitante: _toInt(json['puntosVisitante'] ?? json['resultadoVisitante'] ?? 0),
      fecha: _formatearFecha(fechaRaw),
      hora: _formatearHora(fechaRaw),
      pabellon: json['pabellon']?.toString() ?? json['ubicacion']?.toString() ?? '',
      direccionPabellon: json['direccionPabellon']?.toString() ??
          json['direccion_pabellon']?.toString() ??
          json['ubicacion']?.toString() ?? '',
      ligaId: _toIntOrNull(json['ligaId'] ?? json['liga_id']),
      arbitroId: _toIntOrNull(json['arbitroId'] ?? json['arbitro_id']),
      nombreArbitro: json['nombreArbitro'],
      estado: json['estado']?.toString() ?? 'PROGRAMADO',
      actaUrl: json['actaUrl']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? '',
      fechaCreacion: _formatearFecha(json['fechaCreacion'] ?? json['fecha_creacion']),
      fechaActualizacion: _formatearFecha(json['fechaActualizacion'] ?? json['fecha_actualizacion']),
      tieneActa: json['tieneActa'] as bool?,
      actaId: _toIntOrNull(json['actaId']),
      tieneAlineacionLocal: json['tieneAlineacionLocal'] as bool?,
      tieneAlineacionVisitante: json['tieneAlineacionVisitante'] as bool?,
      alineacionLocalId: _toIntOrNull(json['alineacionLocalId']),
      alineacionVisitanteId: _toIntOrNull(json['alineacionVisitanteId']),
      jornada: _toIntOrNull(json['jornada']),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipoLocalId': equipoLocalId,
      'equipoVisitanteId': equipoVisitanteId,
      'nombreLocal': nombreLocal,
      'nombreVisitante': nombreVisitante,
      'puntosLocal': puntosLocal,
      'puntosVisitante': puntosVisitante,
      'fecha': fecha,
      'hora': hora,
      'pabellon': pabellon,
      'direccionPabellon': direccionPabellon,
      'ligaId': ligaId,
      'arbitroId': arbitroId,
      'estado': estado,
      'jornada': jornada,
    };
  }

  // ============================================================
  // GETTERS
  // ============================================================

  bool get esProgramado => estado == 'PROGRAMADO';
  bool get esFinalizado => estado == 'FINALIZADO';
  bool get esEnCurso => estado == 'EN_CURSO';

  String get resultadoTexto {
    if (esProgramado) return 'VS';
    return '$puntosLocal - $puntosVisitante';
  }

  String get estadoTexto {
    switch (estado) {
      case 'PROGRAMADO': return '📋 PROGRAMADO';
      case 'EN_CURSO': return '⏳ EN CURSO';
      case 'FINALIZADO': return '✅ FINALIZADO';
      default: return estado;
    }
  }

  Color get estadoColor {
    switch (estado) {
      case 'PROGRAMADO': return Colors.orange;
      case 'EN_CURSO': return Colors.blue;
      case 'FINALIZADO': return Colors.green;
      default: return Colors.grey;
    }
  }

  /// Determina si el equipo dado es el local en este partido
  bool esLocalParaEquipo(int equipoId) {
    return equipoLocalId == equipoId;
  }

  /// Devuelve el nombre del rival
  String getRival(int equipoId) {
    if (equipoLocalId == equipoId) {
      return nombreVisitante;
    }
    return nombreLocal;
  }

  /// Devuelve si el equipo tiene alineación presentada
  bool tieneAlineacionParaEquipo(int equipoId) {
    if (equipoLocalId == equipoId) {
      return tieneAlineacionLocal ?? false;
    }
    return tieneAlineacionVisitante ?? false;
  }

  @override
  String toString() {
    return 'Partido{id: $id, $nombreLocal vs $nombreVisitante, $resultadoTexto, $estado}';
  }
}