// lib/services/estadisticas_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class EstadisticasService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ============================================================
  // ESTADÍSTICAS GENERALES
  // ============================================================

  static Future<Map<String, dynamic>> getEstadisticasGenerales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/generales'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        LoggerService.warning('Error ${response.statusCode} obteniendo estadísticas generales',
            tag: 'ESTADISTICAS');
        return _getDefaultStats();
      }
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas generales',
          tag: 'ESTADISTICAS', error: e);
      return _getDefaultStats();
    }
  }

  static Map<String, dynamic> _getDefaultStats() {
    return {
      'totalUsuarios': 0,
      'totalEntrenadores': 0,
      'totalJugadores': 0,
      'totalArbitros': 0,
      'totalEquipos': 0,
      'totalLigas': 0,
      'totalPartidos': 0,
      'partidosHoy': 0,
      'partidosProgramados': 0,
      'partidosFinalizados': 0,
      'usuariosActivos': 0,
      'usuariosBloqueados': 0,
    };
  }

  // ============================================================
  // ESTADÍSTICAS DE JUGADOR
  // ============================================================

  static Future<Map<String, dynamic>> getEstadisticasJugador(int jugadorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/jugador/$jugadorId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del jugador',
          tag: 'ESTADISTICAS', error: e);
      return {};
    }
  }

  // ============================================================
  // TOP JUGADORES
  // ============================================================

  static Future<List<Map<String, dynamic>>> getTopJugadores({
    String ordenar = 'puntos',
    int limite = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/jugadores/top?ordenar=$ordenar&limite=$limite'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggerService.error('Error obteniendo top jugadores',
          tag: 'ESTADISTICAS', error: e);
      return [];
    }
  }

  // ============================================================
  // CLASIFICACIÓN POR LIGA
  // ============================================================

  static Future<List<Map<String, dynamic>>> getClasificacion(int ligaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/clasificacion/$ligaId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggerService.error('Error obteniendo clasificación',
          tag: 'ESTADISTICAS', error: e);
      return [];
    }
  }

  // ============================================================
  // ESTADÍSTICAS DE EQUIPO
  // ============================================================

  static Future<Map<String, dynamic>> getEstadisticasEquipo(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/equipo/$equipoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del equipo',
          tag: 'ESTADISTICAS', error: e);
      return {};
    }
  }

  // ============================================================
  // ESTADÍSTICAS DE PARTIDO
  // ============================================================

  static Future<Map<String, dynamic>> getEstadisticasPartido(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/partido/$partidoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas del partido',
          tag: 'ESTADISTICAS', error: e);
      return {};
    }
  }

  // ============================================================
  // ESTADÍSTICAS RÁPIDAS PARA DASHBOARD
  // ============================================================

  static Future<Map<String, dynamic>> getEstadisticasRapidas() async {
    try {
      // Obtener datos generales y procesar solo lo necesario
      final generales = await getEstadisticasGenerales();

      return {
        'totalEquipos': generales['totalEquipos'] ?? 0,
        'totalPartidos': generales['totalPartidos'] ?? 0,
        'totalJugadores': generales['totalJugadores'] ?? 0,
        'partidosHoy': generales['partidosHoy'] ?? 0,
        'partidosProgramados': generales['partidosProgramados'] ?? 0,
        'partidosFinalizados': generales['partidosFinalizados'] ?? 0,
      };
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas rápidas',
          tag: 'ESTADISTICAS', error: e);
      return {
        'totalEquipos': 0,
        'totalPartidos': 0,
        'totalJugadores': 0,
        'partidosHoy': 0,
        'partidosProgramados': 0,
        'partidosFinalizados': 0,
      };
    }
  }
}