// lib/services/alineacion_service.dart
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
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Presentar alineación
  static Future<Alineacion> presentarAlineacion(Map<String, dynamic> data) async {
    try {
      LoggerService.info('Presentando alineación', tag: 'ALINEACION',
          data: {'partidoId': data['partidoId']});

      final response = await http.post(
        Uri.parse('$baseUrl/alineaciones/presentar'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('POST', '$baseUrl/alineaciones/presentar',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Alineacion.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al presentar alineación');
      }
    } catch (e) {
      LoggerService.error('Error presentando alineación', tag: 'ALINEACION', error: e);
      rethrow;
    }
  }

  // Obtener alineación por partido y equipo
  static Future<Alineacion> getAlineacion(int partidoId, int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alineaciones/partido/$partidoId/equipo/$equipoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Alineacion.fromJson(json.decode(response.body));
      } else {
        throw Exception('Alineación no encontrada');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineación', tag: 'ALINEACION', error: e);
      rethrow;
    }
  }

  // Obtener ambas alineaciones del partido
  static Future<AlineacionesPartido> getAlineacionesPartido(int partidoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alineaciones/partido/$partidoId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return AlineacionesPartido.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar alineaciones');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo alineaciones del partido',
          tag: 'ALINEACION', error: e);
      rethrow;
    }
  }

  // Confirmar alineación
  static Future<Alineacion> confirmarAlineacion(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alineaciones/$id/confirmar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Alineacion.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al confirmar alineación');
      }
    } catch (e) {
      LoggerService.error('Error confirmando alineación', tag: 'ALINEACION', error: e);
      rethrow;
    }
  }
}