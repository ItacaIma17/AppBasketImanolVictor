import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/actaPartido.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';
import 'package:path_provider/path_provider.dart';

class ActaService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<ActaPartido> guardarActa(Map<String, dynamic> actaData) async {
    try {
      LoggerService.info('Guardando acta', tag: 'ACTA', data: {'partidoId': actaData['partidoId']});

      final response = await http.post(
        Uri.parse('$baseUrl/actas/guardar'),
        headers: _headers,
        body: json.encode(actaData),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('POST', '$baseUrl/actas/guardar',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ActaPartido.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al guardar acta');
      }
    } catch (e) {
      LoggerService.error('Error guardando acta', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<ActaPartido> obtenerActaPorPartido(int partidoId) async {
    try {
      LoggerService.info('Obteniendo acta del partido', tag: 'ACTA', data: {'partidoId': partidoId});

      final response = await http.get(
        Uri.parse('$baseUrl/actas/partido/$partidoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/actas/partido/$partidoId',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        return ActaPartido.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Acta no encontrada');
      } else {
        throw Exception('Error al obtener acta');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo acta', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<ActaPartido> obtenerActaPorId(int actaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/$actaId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ActaPartido.fromJson(json.decode(response.body));
      } else {
        throw Exception('Acta no encontrada');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo acta por ID', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<ActaPartido> actualizarActa(int actaId, Map<String, dynamic> actaData) async {
    try {
      LoggerService.info('Actualizando acta', tag: 'ACTA', data: {'actaId': actaId});

      final response = await http.put(
        Uri.parse('$baseUrl/actas/$actaId'),
        headers: _headers,
        body: json.encode(actaData),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('PUT', '$baseUrl/actas/$actaId',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        return ActaPartido.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar acta');
      }
    } catch (e) {
      LoggerService.error('Error actualizando acta', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<void> eliminarActa(int actaId) async {
    try {
      LoggerService.info('Eliminando acta', tag: 'ACTA', data: {'actaId': actaId});

      final response = await http.delete(
        Uri.parse('$baseUrl/actas/$actaId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('DELETE', '$baseUrl/actas/$actaId',
          statusCode: response.statusCode);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar acta');
      }
    } catch (e) {
      LoggerService.error('Error eliminando acta', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<File> descargarActaPdf(int partidoId) async {
    try {
      LoggerService.info('Descargando PDF del acta', tag: 'ACTA', data: {'partidoId': partidoId});

      final response = await http.get(
        Uri.parse('$baseUrl/actas/partido/$partidoId/pdf'),
        headers: _headers,
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {

        final directory = await getApplicationDocumentsDirectory();

        final file = File('${directory.path}/acta_partido_$partidoId.pdf');

        await file.writeAsBytes(response.bodyBytes);

        LoggerService.info('PDF descargado exitosamente', tag: 'ACTA',
            data: {'path': file.path, 'size': response.bodyBytes.length});

        return file;
      } else {
        throw Exception('Error al descargar PDF');
      }
    } catch (e) {
      LoggerService.error('Error descargando PDF', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<bool> tieneActa(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/partido/$partidoId/existe'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['existe'] ?? false;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error verificando existencia de acta', tag: 'ACTA', error: e);
      return false;
    }
  }

  static Future<bool> puedeEditarActa(int actaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/$actaId/puede-editar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['puedeEditar'] ?? false;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error verificando permisos de edición', tag: 'ACTA', error: e);
      return false;
    }
  }

  static Future<List<ActaPartido>> listarTodasActas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ActaPartido.fromJson(e)).toList();
      } else {
        throw Exception('Error al listar actas');
      }
    } catch (e) {
      LoggerService.error('Error listando actas', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<List<ActaPartido>> listarActasPorArbitro(int arbitroId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/arbitro/$arbitroId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ActaPartido.fromJson(e)).toList();
      } else {
        throw Exception('Error al listar actas del árbitro');
      }
    } catch (e) {
      LoggerService.error('Error listando actas por árbitro', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<List<ActaPartido>> listarActasPorEquipo(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/equipo/$equipoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ActaPartido.fromJson(e)).toList();
      } else {
        throw Exception('Error al listar actas del equipo');
      }
    } catch (e) {
      LoggerService.error('Error listando actas por equipo', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getEstadisticasJugador(int partidoId, int jugadorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/partido/$partidoId/jugador/$jugadorId/estadisticas'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas del jugador');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del jugador', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getEstadisticasEquipo(int partidoId, int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/partido/$partidoId/equipo/$equipoId/estadisticas'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas del equipo');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del equipo', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<void> compartirActaPorEmail(int actaId, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/actas/$actaId/compartir'),
        headers: _headers,
        body: json.encode({'email': email}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al compartir acta');
      }

      LoggerService.info('Acta compartida por email', tag: 'ACTA', data: {'actaId': actaId, 'email': email});
    } catch (e) {
      LoggerService.error('Error compartiendo acta', tag: 'ACTA', error: e);
      rethrow;
    }
  }

  static Future<bool> existeActa(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actas/partido/$partidoId/existe'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['existe'] ?? false;
      }
      return false;
    } catch (e) {
      LoggerService.error('Error verificando existencia de acta', tag: 'ACTA', error: e);
      return false;
    }
  }
}
