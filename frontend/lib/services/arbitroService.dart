// lib/services/arbitro_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/arbitro.dart';
import '../models/partido.dart';
import '../models/partidoAsignado.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class ArbitroService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, String>> _getHeadersAsync() async {
    final token = await AutenticacionService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // OBTENER ÁRBITROS
  // ============================================================

  // Listar todos los árbitros
  // lib/services/arbitro_service.dart - VERIFICAR ESTOS MÉTODOS

// Listar todos los árbitros
  static Future<List<Arbitro>> listarArbitros() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Arbitro.fromJson(e)).toList();
      } else {
        throw Exception('Error al listar árbitros: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando árbitros', tag: 'ARBITRO', error: e);
      return [];
    }
  }

// Listar árbitros disponibles (sin partidos asignados)
  static Future<List<Arbitro>> listarArbitrosDisponibles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/disponibles'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Arbitro.fromJson(e)).toList();
      } else {
        throw Exception('Error al listar árbitros disponibles: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando árbitros disponibles', tag: 'ARBITRO', error: e);
      return [];
    }
  }

  // Obtener árbitro por ID
  static Future<Arbitro> obtenerArbitroPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Arbitro.fromJson(json.decode(response.body));
      } else {
        throw Exception('Árbitro no encontrado');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo árbitro', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // Obtener árbitro por username
  static Future<Arbitro> obtenerArbitroPorUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/username/$username'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Arbitro.fromJson(json.decode(response.body));
      } else {
        throw Exception('Árbitro no encontrado');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo árbitro por username', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }



  // ============================================================
  // CREAR, ACTUALIZAR, ELIMINAR ÁRBITROS
  // ============================================================

  // Crear nuevo árbitro (solo admin)
  static Future<Arbitro> crearArbitro(Map<String, dynamic> arbitroData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/arbitros/crear'),
        headers: _headers,
        body: json.encode(arbitroData),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('POST', '$baseUrl/arbitros/crear',
          statusCode: response.statusCode, requestBody: arbitroData, response: response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Arbitro.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear árbitro');
      }
    } catch (e) {
      LoggerService.error('Error creando árbitro', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // Actualizar árbitro
  static Future<Arbitro> actualizarArbitro(int id, Map<String, dynamic> arbitroData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/arbitros/$id'),
        headers: _headers,
        body: json.encode(arbitroData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Arbitro.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar árbitro');
      }
    } catch (e) {
      LoggerService.error('Error actualizando árbitro', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // Eliminar árbitro (solo admin)
  static Future<void> eliminarArbitro(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/arbitros/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar árbitro');
      }
    } catch (e) {
      LoggerService.error('Error eliminando árbitro', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // Cambiar estado del árbitro (activar/desactivar)
  static Future<void> cambiarEstadoArbitro(int id, bool activo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/arbitros/$id/estado'),
        headers: _headers,
        body: json.encode({'activo': activo}),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('PUT', '$baseUrl/arbitros/$id/estado',
          statusCode: response.statusCode, requestBody: {'activo': activo}, response: response.body);

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al cambiar estado');
      }
    } catch (e) {
      LoggerService.error('Error cambiando estado del árbitro', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // ============================================================
  // PARTIDOS ASIGNADOS
  // ============================================================

  // Obtener partidos asignados al árbitro autenticado
  static Future<List<Partido>> getMisPartidos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/mis-partidos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/arbitros/mis-partidos',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Partido.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar partidos del árbitro');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo partidos del árbitro', tag: 'ARBITRO', error: e);
      return [];
    }
  }

  // Obtener próximos partidos del árbitro
  static Future<List<Partido>> getProximosPartidos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/proximos-partidos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Partido.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar próximos partidos');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo próximos partidos', tag: 'ARBITRO', error: e);
      return [];
    }
  }

  // Obtener partidos finalizados del árbitro
  static Future<List<Partido>> getPartidosFinalizados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/partidos-finalizados'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Partido.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar partidos finalizados');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo partidos finalizados', tag: 'ARBITRO', error: e);
      return [];
    }
  }

  // Obtener detalle de un partido específico
  static Future<Partido> getPartidoById(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/partidos/$partidoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Partido.fromJson(json.decode(response.body));
      } else {
        throw Exception('Partido no encontrado');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo partido', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // ============================================================
  // ALINEACIONES
  // ============================================================

  // lib/services/arbitro_service.dart - ACTUALIZAR ESTE MÉTODO

  /// Obtener alineaciones de un partido (formato simple para compatibilidad)
  static Future<Map<String, dynamic>> getAlineacionesPartido(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/partido/$partidoId/alineaciones'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/arbitros/partido/$partidoId/alineaciones',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'alineacionLocal': null,
          'alineacionVisitante': null,
          'equipoLocalNombre': '',
          'equipoVisitanteNombre': '',
        };
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineaciones', tag: 'ARBITRO', error: e);
      return {
        'alineacionLocal': null,
        'alineacionVisitante': null,
        'equipoLocalNombre': '',
        'equipoVisitanteNombre': '',
      };
    }
  }

  // ============================================================
  // ACTAS
  // ============================================================

  // Verificar si el árbitro puede editar un acta
  static Future<bool> puedeEditarActa(int actaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/$actaId/puede-editar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['puedeEditar'] ?? false;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error verificando permisos', tag: 'ARBITRO', error: e);
      return false;
    }
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  // Obtener estadísticas del árbitro
  static Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/mis-estadisticas'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar estadísticas');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del árbitro', tag: 'ARBITRO', error: e);
      return {};
    }
  }

  // ============================================================
  // ASIGNACIONES (ADMIN)
  // ============================================================

  // Asignar árbitro a un partido (solo admin)
  static Future<void> asignarArbitroAPartido(int partidoId, int arbitroId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/partidos/$partidoId/arbitro/$arbitroId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al asignar árbitro');
      }
    } catch (e) {
      LoggerService.error('Error asignando árbitro a partido', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // Desasignar árbitro de un partido (solo admin)
  static Future<void> desasignarArbitro(int partidoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/partidos/$partidoId/arbitro'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al desasignar árbitro');
      }
    } catch (e) {
      LoggerService.error('Error desasignando árbitro', tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // Obtener partidos sin árbitro asignado (solo admin)
  static Future<List<Partido>> getPartidosSinArbitro() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/partidos-sin-arbitro'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Partido.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar partidos sin árbitro');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo partidos sin árbitro', tag: 'ARBITRO', error: e);
      return [];
    }
  }



  // lib/services/arbitro_service.dart - AÑADIR ESTOS MÉTODOS

  // ============================================================
  // ALINEACIONES PARA ACTA (ARBITRO)
  // ============================================================

  /// Obtener alineaciones de un partido para el acta (con estructura completa).
  ///
  /// El backend (`AlineacionesPartidoDTO`) devuelve:
  ///   { partidoId, equipoLocal, equipoVisitante,
  ///     alineacionLocal: AlineacionResponseDTO,
  ///     alineacionVisitante: AlineacionResponseDTO,
  ///     ambasPresentadas, ... }
  /// y cada jugador trae los campos `jugadorId, nombre, apellido, dorsal,
  /// posicion, titular` (NO `nombreJugador`).
  static Future<Map<String, dynamic>> getAlineacionesParaActa(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/partido/$partidoId/alineaciones'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/arbitros/partido/$partidoId/alineaciones',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ✅ FIX: leer `equipoLocal`/`equipoVisitante` (no `*Nombre`).
        final nombreLocal = (data['equipoLocal'] ??
                data['equipoLocalNombre'] ?? // compat por si algún build viejo
                'Local')
            .toString();
        final nombreVisitante = (data['equipoVisitante'] ??
                data['equipoVisitanteNombre'] ??
                'Visitante')
            .toString();

        return {
          'alineacionLocal': _parseAlineacion(data['alineacionLocal'], nombreLocal),
          'alineacionVisitante': _parseAlineacion(data['alineacionVisitante'], nombreVisitante),
          'ambasPresentadas': data['ambasPresentadas'] ?? false,
        };
      } else {
        return {'alineacionLocal': null, 'alineacionVisitante': null, 'ambasPresentadas': false};
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineaciones para acta', tag: 'ARBITRO', error: e);
      return {'alineacionLocal': null, 'alineacionVisitante': null, 'ambasPresentadas': false};
    }
  }

  /// Parsear una alineación individual.
  ///
  /// Devuelve un mapa con `nombreEquipo`, `jugadores` (titulares + suplentes
  /// concatenados con flag `titular`) y `confirmada`.
  static Map<String, dynamic>? _parseAlineacion(dynamic alineacion, String nombreEquipo) {
    if (alineacion == null) return null;

    String _nombreCompleto(Map j) {
      // El backend serializa el JugadorAlineacionRequestDTO con `nombre` +
      // `apellido`. Mantenemos compatibilidad con `nombreJugador` por si
      // se llama desde otra ruta antigua.
      final nombre = (j['nombre'] ?? j['nombreJugador'] ?? '').toString().trim();
      final apellido = (j['apellido'] ?? '').toString().trim();
      if (apellido.isEmpty) return nombre;
      return '$nombre $apellido'.trim();
    }

    final List<Map<String, dynamic>> jugadores = [];

    final titulares = (alineacion['titulares'] as List?) ?? const [];
    for (final raw in titulares) {
      if (raw is! Map) continue;
      jugadores.add({
        'jugadorId': raw['jugadorId'],
        'nombre': _nombreCompleto(raw),
        'nombreJugador': _nombreCompleto(raw), // alias para compatibilidad
        'dorsal': raw['dorsal'],
        'posicion': raw['posicion'],
        'titular': true,
      });
    }

    final suplentes = (alineacion['suplentes'] as List?) ?? const [];
    for (final raw in suplentes) {
      if (raw is! Map) continue;
      jugadores.add({
        'jugadorId': raw['jugadorId'],
        'nombre': _nombreCompleto(raw),
        'nombreJugador': _nombreCompleto(raw),
        'dorsal': raw['dorsal'],
        'posicion': raw['posicion'],
        'titular': false,
      });
    }

    return {
      'nombreEquipo': nombreEquipo,
      'jugadores': jugadores,
      'confirmada': alineacion['confirmada'] ?? false,
    };
  }


  /// Confirmar las alineaciones de ambos equipos (árbitro)
  static Future<Map<String, dynamic>> confirmarAlineaciones(int partidoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/arbitros/partido/$partidoId/confirmar-alineaciones'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'ok': true, 'message': data['message']};
      } else {
        return {'ok': false, 'message': data['message'] ?? 'Error al confirmar'};
      }
    } catch (e) {
      LoggerService.error('Error confirmando alineaciones', tag: 'ARBITRO', error: e);
      return {'ok': false, 'message': e.toString()};
    }
  }

  /// Verificar estado de alineaciones del partido
  static Future<Map<String, dynamic>> estadoAlineaciones(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/partido/$partidoId/alineaciones'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'localPresentada': data['alineacionLocal'] != null,
          'visitantePresentada': data['alineacionVisitante'] != null,
          'ambasConfirmadas': data['ambasPresentadas'] ?? false,
        };
      }
      return {'localPresentada': false, 'visitantePresentada': false, 'ambasConfirmadas': false};
    } catch (e) {
      return {'localPresentada': false, 'visitantePresentada': false, 'ambasConfirmadas': false};
    }
  }

  /// Verificar si un partido tiene alineaciones de ambos equipos
  static Future<bool> tieneAlineacionesCompletas(int partidoId) async {
    try {
      final alineaciones = await getAlineacionesParaActa(partidoId);
      return alineaciones['ambasPresentadas'] == true;
    } catch (e) {
      return false;
    }
  }
}