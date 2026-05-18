import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/AlineacionesPartido.dart';
import '../models/alineacion.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class AlineacionService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Alineacion> presentarAlineacion(Map<String, dynamic> data) async {
    try {
      LoggerService.info('Presentando alineación', tag: 'ALINEACION',
          data: {'partidoId': data['partidoId'], 'equipoId': data['equipoId']});

      final response = await http.post(
        Uri.parse('$baseUrl/alineaciones/presentar'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('POST', '$baseUrl/alineaciones/presentar',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          throw Exception('Respuesta vacía del servidor');
        }
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Alineacion.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        String errorMsg = 'Error al presentar alineación';
        try {
          if (response.body.isNotEmpty) {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          }
        } catch (e) {
          errorMsg = 'Error ${response.statusCode}: ${response.body}';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error presentando alineación', tag: 'ALINEACION', error: e);
      rethrow;
    }
  }

  static Future<Alineacion?> getAlineacion(int partidoId, int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alineaciones/partido/$partidoId/equipo/$equipoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return Alineacion.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineación', tag: 'ALINEACION', error: e);
      return null;
    }
  }

  static Future<Map<String, dynamic>> getAlineacionesPartido(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alineaciones/partido/$partidoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/alineaciones/partido/$partidoId',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'local': null, 'visitante': null};
        }
        final data = json.decode(response.body);

        return {
          'local': data['alineacionLocal'] != null ? {
            'id': data['alineacionLocal']['id'],
            'nombreEquipo': data['equipoLocal'] ?? data['nombreLocal'] ?? 'Local',
            'jugadores': _procesarJugadoresAlineacion(data['alineacionLocal']),
            'confirmada': data['alineacionLocal']['confirmada'] ?? false,
          } : null,
          'visitante': data['alineacionVisitante'] != null ? {
            'id': data['alineacionVisitante']['id'],
            'nombreEquipo': data['equipoVisitante'] ?? data['nombreVisitante'] ?? 'Visitante',
            'jugadores': _procesarJugadoresAlineacion(data['alineacionVisitante']),
            'confirmada': data['alineacionVisitante']['confirmada'] ?? false,
          } : null,
        };
      } else if (response.statusCode == 404) {
        return {'local': null, 'visitante': null};
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineaciones del partido',
          tag: 'ALINEACION', error: e);
      return {'local': null, 'visitante': null};
    }
  }

  static Future<Map<String, dynamic>?> getAlineacionEquipo(int partidoId, int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alineaciones/partido/$partidoId/equipo/$equipoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineación del equipo', tag: 'ALINEACION', error: e);
      return null;
    }
  }

  static List<Map<String, dynamic>> _procesarJugadoresAlineacion(Map<String, dynamic> alineacion) {
    final List<Map<String, dynamic>> jugadores = [];

    if (alineacion['titulares'] != null) {
      for (var j in alineacion['titulares']) {
        jugadores.add({
          'jugadorId': j['jugadorId'],
          'nombre': j['nombreJugador'],
          'dorsal': j['dorsal'],
          'posicion': j['posicion'],
          'esTitular': true,
        });
      }
    }

    if (alineacion['suplentes'] != null) {
      for (var j in alineacion['suplentes']) {
        jugadores.add({
          'jugadorId': j['jugadorId'],
          'nombre': j['nombreJugador'],
          'dorsal': j['dorsal'],
          'posicion': j['posicion'],
          'esTitular': false,
        });
      }
    }

    return jugadores;
  }

  static Future<Alineacion> confirmarAlineacion(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alineaciones/$id/confirmar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Respuesta vacía del servidor');
        }
        return Alineacion.fromJson(json.decode(response.body));
      } else {
        String errorMsg = 'Error al confirmar alineación';
        try {
          if (response.body.isNotEmpty) {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          }
        } catch (e) {
          errorMsg = 'Error ${response.statusCode}: ${response.body}';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error confirmando alineación', tag: 'ALINEACION', error: e);
      rethrow;
    }
  }

  static Future<Alineacion> actualizarAlineacion(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alineaciones/$id'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Alineacion.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar alineación');
      }
    } catch (e) {
      LoggerService.error('Error actualizando alineación', tag: 'ALINEACION', error: e);
      rethrow;
    }
  }

  static Future<void> eliminarAlineacion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/alineaciones/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar alineación');
      }
    } catch (e) {
      LoggerService.error('Error eliminando alineación', tag: 'ALINEACION', error: e);
      rethrow;
    }
  }

  static Future<bool> existeAlineacion(int partidoId, int equipoId) async {
    try {
      final alineacion = await getAlineacion(partidoId, equipoId);
      return alineacion != null;
    } catch (e) {
      return false;
    }
  }
}
