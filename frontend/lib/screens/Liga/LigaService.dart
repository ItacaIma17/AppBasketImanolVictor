// lib/services/liga_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../services/autenticacion_service.dart';


class LigaService {
  static String get baseUrl => AppConfig.apiUrl;

  static Future<List<Map<String, dynamic>>> listarLigas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/ligas/listar'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al listar ligas');
    }
  }

  static Future<void> crearLiga(Map<String, dynamic> data) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/ligas/crear'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear liga');
    }
  }

  static Future<void> eliminarLiga(int id) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/ligas/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar liga');
    }
  }
}