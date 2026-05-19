import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/liga.dart';
import '../../services/autenticacion_service.dart';
import '../../services/loggerService.dart';

class LigaService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<Liga>> listarLigas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ligas/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Liga.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      LoggerService.error('Error listando ligas', tag: 'LIGA', error: e);
      return [];
    }
  }

  static Future<Map<String, dynamic>> crearLiga(Map<String, dynamic> ligaData) async {
    try {
      final requestData = {
        'nombreLiga': ligaData['nombreLiga']?.trim(),
        'pais': ligaData['pais'] ?? 'España',
        'numeroEquipos': ligaData['numeroEquipos'] ?? 0,
        'temporada': ligaData['temporada'],
      };

      final response = await http.post(
        Uri.parse('$baseUrl/ligas/crear'),
        headers: _headers,
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear liga');
      }
    } catch (e) {
      LoggerService.error('Error creando liga', tag: 'LIGA', error: e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> actualizarLiga(int id, Map<String, dynamic> ligaData) async {
    try {
      final requestData = {
        'nombreLiga': ligaData['nombreLiga']?.trim(),
        'pais': ligaData['pais'] ?? 'España',
        'numeroEquipos': ligaData['numeroEquipos'] ?? 0,
        'temporada': ligaData['temporada'],
      };

      final response = await http.put(
        Uri.parse('$baseUrl/ligas/$id'),
        headers: _headers,
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar liga');
      }
    } catch (e) {
      LoggerService.error('Error actualizando liga', tag: 'LIGA', error: e);
      rethrow;
    }
  }

  static Future<void> eliminarLiga(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ligas/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar liga');
      }
    } catch (e) {
      LoggerService.error('Error eliminando liga', tag: 'LIGA', error: e);
      rethrow;
    }
  }
}
