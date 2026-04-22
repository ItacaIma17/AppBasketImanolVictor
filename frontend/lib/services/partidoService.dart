// lib/services/partido_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'autenticacion_service.dart';

class PartidoService {
  static String get baseUrl => AppConfig.apiUrl;

  static Future<List<Map<String, dynamic>>> listarPartidos() async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/partidos/listar'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al listar partidos');
    }
  }

  static Future<void> crearPartido(Map<String, dynamic> data) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/partidos/crear'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear partido');
    }
  }

  static Future<void> actualizarResultado(int id, Map<String, dynamic> data) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.put(
      Uri.parse('$baseUrl/partidos/$id/resultado'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar resultado');
    }
  }

  static Future<void> eliminarPartido(int id) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/partidos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar partido');
    }
  }
}