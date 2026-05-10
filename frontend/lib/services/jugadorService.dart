import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/EstadisticasJugador.dart';
import '../models/jugador.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class JugadorService {
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

  static Future<List<Jugador>> listarJugadores() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/jugadores/listar',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al listar jugadores: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando jugadores', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<Jugador>> listarJugadoresPorEquipo(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/equipo/$equipoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al listar jugadores del equipo');
      }
    } catch (e) {
      LoggerService.error('Error listando jugadores por equipo', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<Jugador>> listarJugadoresSinEquipo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/sin-equipo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al listar jugadores sin equipo');
      }
    } catch (e) {
      LoggerService.error('Error listando jugadores sin equipo', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<Jugador>> listarJugadoresDestacados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/destacados'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al listar jugadores destacados');
      }
    } catch (e) {
      LoggerService.error('Error listando jugadores destacados', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<Jugador> obtenerJugadorPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Jugador.fromJson(json.decode(response.body));
      } else {
        throw Exception('Jugador no encontrado');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo jugador por ID', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<Jugador> obtenerJugadorPorUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/username/$username'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Jugador.fromJson(json.decode(response.body));
      } else {
        throw Exception('Jugador no encontrado');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo jugador por username', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<Jugador> crearJugador(Map<String, dynamic> jugadorData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jugadores/crear'),
        headers: _headers,
        body: json.encode(jugadorData),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('POST', '$baseUrl/jugadores/crear',
          statusCode: response.statusCode, requestBody: jugadorData, response: response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Jugador.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear jugador');
      }
    } catch (e) {
      LoggerService.error('Error creando jugador', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<Jugador> actualizarJugador(int id, Map<String, dynamic> jugadorData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jugadores/$id'),
        headers: _headers,
        body: json.encode(jugadorData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Jugador.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar jugador');
      }
    } catch (e) {
      LoggerService.error('Error actualizando jugador', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<void> eliminarJugador(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/jugadores/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar jugador');
      }
    } catch (e) {
      LoggerService.error('Error eliminando jugador', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<void> asignarJugadorAEquipo(int jugadorId, int equipoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jugadores/$jugadorId/asignar-equipo/$equipoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al asignar jugador a equipo');
      }
    } catch (e) {
      LoggerService.error('Error asignando jugador a equipo', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<void> desasignarJugadorDeEquipo(int jugadorId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/jugadores/$jugadorId/desasignar-equipo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al desasignar jugador');
      }
    } catch (e) {
      LoggerService.error('Error desasignando jugador', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<EstadisticasJugador> obtenerEstadisticasJugador(int jugadorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/$jugadorId/estadisticas'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return EstadisticasJugador.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener estadísticas');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del jugador', tag: 'JUGADOR', error: e);
      rethrow;
    }
  }

  static Future<List<Jugador>> getRankingPuntos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/ranking/puntos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener ranking');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo ranking de puntos', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<Jugador>> getRankingRebotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/ranking/rebotes'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener ranking');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo ranking de rebotes', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<Jugador>> getRankingAsistencias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/ranking/asistencias'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener ranking');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo ranking de asistencias', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<dynamic>> getMisPartidos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/mis-partidos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar partidos');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo partidos del jugador', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<Jugador>> buscarJugadores(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/buscar?q=$query'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al buscar jugadores');
      }
    } catch (e) {
      LoggerService.error('Error buscando jugadores', tag: 'JUGADOR', error: e);
      return [];
    }
  }

  static Future<List<Jugador>> buscarJugadoresPorPosicion(String posicion) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/posicion/$posicion'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Jugador.fromJson(item)).toList();
      } else {
        throw Exception('Error al buscar jugadores por posición');
      }
    } catch (e) {
      LoggerService.error('Error buscando jugadores por posición', tag: 'JUGADOR', error: e);
      return [];
    }
  }
}
