// lib/services/entrenador_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/entrenador.dart';
import '../models/entrenadorEquipo.dart';
import 'autenticacion_service.dart';

class EntrenadorService {
  static String get baseUrl => AppConfig.apiUrl;

  // Generar código de entrenador (admin)
  static Future<String> generarCodigo() async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/entrenadores/generar-codigo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['codigo'];
    } else {
      throw Exception('Error al generar código: ${response.statusCode}');
    }
  }

  // Crear entrenador (admin)
  static Future<Entrenador> crearEntrenador(Map<String, dynamic> data) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/entrenadores/crear'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Entrenador.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear entrenador');
    }
  }

  // Asignar equipo a entrenador (admin)
  static Future<EntrenadorEquipo> asignarEquipo({
    required String codigoEntrenador,
    required int equipoId,
  }) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/entrenadores/asignar-equipo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'codigoEntrenador': codigoEntrenador,
        'equipoId': equipoId,
      }),
    );

    if (response.statusCode == 200) {
      return EntrenadorEquipo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al asignar equipo: ${response.statusCode}');
    }
  }

  // Obtener mi equipo (entrenador autenticado)
  static Future<EntrenadorEquipo> obtenerMiEquipo() async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/entrenadores/mi-equipo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return EntrenadorEquipo.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Aún no tienes equipo asignado');
    } else {
      throw Exception('Error al obtener equipo');
    }
  }

  // Listar todos los entrenadores (admin)
  static Future<List<Entrenador>> listarEntrenadores() async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/entrenadores/listar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Entrenador.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar entrenadores');
    }
  }

  // Listar entrenadores sin equipo (admin)
  static Future<List<Entrenador>> listarEntrenadoresSinEquipo() async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/entrenadores/sin-equipo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Entrenador.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar entrenadores sin equipo');
    }
  }

  // Listar entrenadores con equipo (admin)
  static Future<List<Entrenador>> listarEntrenadoresConEquipo() async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/entrenadores/con-equipo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Entrenador.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar entrenadores con equipo');
    }
  }

  // Obtener entrenador por ID
  static Future<Entrenador> obtenerEntrenadorPorId(int id) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/entrenadores/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Entrenador.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener entrenador');
    }
  }

  // Eliminar entrenador
  static Future<void> eliminarEntrenador(int id) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/entrenadores/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar entrenador');
    }
  }
}