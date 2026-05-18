import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/equipo.dart';
import '../models/jugador.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class EquipoService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<Equipo>> listarEquipos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final equipos = <Equipo>[];
        for (int i = 0; i < data.length; i++) {
          try {
            equipos.add(Equipo.fromJson(data[i]));
          } catch (e) {
            LoggerService.warning('Error parseando equipo[$i]: $e');
          }
        }
        return equipos;
      } else {
        throw Exception('Error al cargar equipos: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando equipos: $e');
      rethrow;
    }
  }

  static Future<List<Equipo>> listarEquiposPorLiga(int ligaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/liga/$ligaId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar equipos de la liga: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando equipos por liga $ligaId: $e');
      rethrow;
    }
  }

  static Future<List<Equipo>> listarEquiposSinEntrenador() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/sin-entrenador'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar equipos sin entrenador: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando equipos sin entrenador: $e');
      rethrow;
    }
  }

  static Future<List<Equipo>> listarEquiposConSolicitudPendiente() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/solicitudes-pendientes'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar solicitudes pendientes: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando solicitudes pendientes: $e');
      rethrow;
    }
  }

  static Future<Equipo> crearEquipo(Map<String, dynamic> equipoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipos/crear'),
        headers: _headers,
        body: json.encode(equipoData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear equipo');
      }
    } catch (e) {
      LoggerService.error('Error creando equipo: $e');
      rethrow;
    }
  }

  static Future<Equipo> obtenerEquipo(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Equipo no encontrado');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo equipo $id: $e');
      rethrow;
    }
  }

  static Future<List<Jugador>> getJugadoresEquipo(int equipoId) async {
    try {
      final token = AutenticacionService.token;
      if (token == null) {
        LoggerService.warning('No hay token disponible');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$equipoId/jugadores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Jugador.fromJson(j)).toList();
      } else {
        LoggerService.warning('Error obteniendo jugadores: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      LoggerService.error('Error obteniendo jugadores del equipo $equipoId: $e');
      return [];
    }
  }

  static Future<Equipo> obtenerEquipoPorCodigo(String codigo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/codigo/$codigo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Código de equipo inválido');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo equipo por código $codigo: $e');
      rethrow;
    }
  }

  static Future<Equipo> actualizarEquipo(int id, Map<String, dynamic> equipoData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
        body: json.encode(equipoData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar equipo');
      }
    } catch (e) {
      LoggerService.error('Error actualizando equipo $id: $e');
      rethrow;
    }
  }

  static Future<void> solicitarDirigirEquipo(String codigoSolicitud) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipos/solicitar'),
        headers: _headers,
        body: json.encode({'codigoSolicitud': codigoSolicitud}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al solicitar equipo');
      }
    } catch (e) {
      LoggerService.error('Error solicitando equipo con código $codigoSolicitud: $e');
      rethrow;
    }
  }

  static Future<Equipo> aprobarSolicitud({
    required String codigoSolicitud,
    required int entrenadorId,
    required bool aprobar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipos/aprobar-solicitud'),
        headers: _headers,
        body: json.encode({
          'codigoSolicitud': codigoSolicitud,
          'entrenadorId': entrenadorId,
          'aprobar': aprobar,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al procesar solicitud');
      }
    } catch (e) {
      LoggerService.error('Error aprobando solicitud: $e');
      rethrow;
    }
  }

  static Future<void> eliminarEquipo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar equipo');
      }
    } catch (e) {
      LoggerService.error('Error eliminando equipo $id: $e');
      rethrow;
    }
  }

  static Future<String> regenerarCodigoSolicitud(int equipoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipos/$equipoId/regenerar-codigo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['codigoSolicitud'];
      } else {
        throw Exception('Error al regenerar código');
      }
    } catch (e) {
      LoggerService.error('Error regenerando código para equipo $equipoId: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerEstadisticasEquipo(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$equipoId/estadisticas'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar estadísticas');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del equipo $equipoId: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> obtenerProximosPartidos(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$equipoId/proximos-partidos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar próximos partidos');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo próximos partidos del equipo $equipoId: $e');
      rethrow;
    }
  }
}