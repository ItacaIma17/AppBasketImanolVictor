// lib/services/partidoService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/partido.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class PartidoService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Listar todos los partidos
  static Future<List<Partido>> listarPartidos() async {
    try {
      LoggerService.info('Listando partidos', tag: 'PARTIDOS');

      // Verificar token antes de la petición
      final token = AutenticacionService.token;
      if (token == null) {
        LoggerService.warning('No hay token disponible', tag: 'PARTIDOS');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/partidos/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/partidos/listar',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Partido.fromJson(e)).toList();
      } else if (response.statusCode == 403) {
        LoggerService.error('Acceso denegado a partidos. Verifica el token.', tag: 'PARTIDOS');
        throw Exception('No tienes permiso para ver los partidos');
      } else {
        throw Exception('Error al cargar partidos: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando partidos', tag: 'PARTIDOS', error: e);
      return []; // Retornar lista vacía en lugar de lanzar excepción
    }
  }

// Obtener partidos donde el equipo es local
static Future<List<Partido>> obtenerPartidosPorEquipoLocal(int equipoId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/partidos/equipo/$equipoId/local'),
      headers: _headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Partido.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print('❌ Error obteniendo partidos como local: $e');
    return [];
  }
}

// Obtener partidos donde el equipo es visitante
static Future<List<Partido>> obtenerPartidosPorEquipoVisitante(int equipoId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/partidos/equipo/$equipoId/visitante'),
      headers: _headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Partido.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print('❌ Error obteniendo partidos como visitante: $e');
    return [];
  }
}

  // Crear partido (solo admin)
  static Future<Map<String, dynamic>> crearPartido(Map<String, dynamic> partidoData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/partidos/crear'),
        headers: _headers,
        body: json.encode(partidoData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear partido');
      }
    } catch (e) {
      print('❌ Error creando partido: $e');
      rethrow;
    }
  }

  // Actualizar resultado
  static Future<void> actualizarResultado(int partidoId, Map<String, dynamic> resultado) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/partidos/$partidoId/resultado'),
        headers: _headers,
        body: json.encode(resultado),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar resultado');
      }
    } catch (e) {
      print('❌ Error actualizando resultado: $e');
      rethrow;
    }
  }

  static Future<List<Partido>> getPartidosEntrenador() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/partidos/entrenador/mis-partidos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Partido.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar partidos');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo partidos del entrenador',
          tag: 'PARTIDO', error: e);
      rethrow;
    }
  }

  // lib/services/partido_service.dart

  static Future<List<Partido>> getProximosPartidosEquipo(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/partidos/equipo/$equipoId/proximos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Partido.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error obteniendo próximos partidos: $e');
      return [];
    }
  }

  // Eliminar partido
  static Future<void> eliminarPartido(int partidoId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/partidos/$partidoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar partido');
      }
    } catch (e) {
      print('❌ Error eliminando partido: $e');
      rethrow;
    }
  }
}