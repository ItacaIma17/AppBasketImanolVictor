// lib/screens/Liga/LigaService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/autenticacion_service.dart';

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

  // Listar todas las ligas
  static Future<List<Map<String, dynamic>>> listarLigas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ligas/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      print('📡 Listar ligas response: ${response.statusCode}');
      print('📡 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception('Error al cargar ligas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error listando ligas: $e');
      rethrow;
    }
  }

  // lib/screens/Liga/LigaService.dart

// Crear nueva liga (solo admin) - VERSIÓN CORREGIDA
  static Future<Map<String, dynamic>> crearLiga(Map<String, dynamic> ligaData) async {
    try {
      // CORREGIDO: Usar los campos correctos que espera el backend
      final requestData = {
        'nombreLiga': ligaData['nombreLiga']?.trim(),
        'pais': ligaData['pais'] ?? 'España',
        'numeroEquipos': ligaData['numeroEquipos'] ?? 0,
      };

      print('📝 Creando liga - Datos enviados: $requestData');
      print('🔐 Headers: ${_headers}');

      final response = await http.post(
        Uri.parse('$baseUrl/ligas/crear'),
        headers: _headers,
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Status code: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Respuesta vacía del servidor');
        }
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos de administrador');
      } else {
        final error = response.body.isNotEmpty ? json.decode(response.body) : {'message': 'Error desconocido'};
        throw Exception(error['message'] ?? 'Error al crear liga');
      }
    } catch (e) {
      print('❌ Error creando liga: $e');
      rethrow;
    }
  }

  // Eliminar liga (solo admin)
  static Future<void> eliminarLiga(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ligas/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      print('📡 Eliminar liga response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar liga');
      }
    } catch (e) {
      print('❌ Error eliminando liga: $e');
      rethrow;
    }
  }

  // Actualizar liga (solo admin)
  static Future<Map<String, dynamic>> actualizarLiga(int id, Map<String, dynamic> ligaData) async {
    try {
      final requestData = {
        'nombreLiga': ligaData['nombreLiga'],
        'pais': ligaData['pais'],
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
      print('❌ Error actualizando liga: $e');
      rethrow;
    }
  }
}