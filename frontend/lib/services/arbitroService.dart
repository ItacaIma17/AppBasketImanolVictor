// lib/services/arbitro_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/partido.dart';
import '../models/alineacion.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class ArbitroService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Obtener partidos asignados al árbitro
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
        throw Exception('Error al cargar partidos');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo partidos del árbitro',
          tag: 'ARBITRO', error: e);
      rethrow;
    }
  }

  // Obtener alineaciones de un partido (para el acta)
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
        throw Exception('Error al cargar alineaciones');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineaciones para acta',
          tag: 'ARBITRO', error: e);
      rethrow;
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
}