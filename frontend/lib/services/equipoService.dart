// lib/services/equipo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/equipo.dart';
import 'autenticacion_service.dart';

class EquipoService {
  static String get baseUrl => AppConfig.apiUrl;

  // Crear equipo (admin)
  static Future<Equipo> crearEquipo(Equipo equipo) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/equipos/crear'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(equipo.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Equipo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al crear equipo: ${response.statusCode}');
    }
  }

  // Obtener equipo por ID
  static Future<Equipo> obtenerEquipoPorId(int id) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/equipos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Equipo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener equipo');
    }
  }

  // Listar todos los equipos
  static Future<List<Equipo>> listarEquipos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/equipos/listar'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Equipo.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar equipos');
    }
  }

  // Listar equipos por liga
  static Future<List<Equipo>> listarEquiposPorLiga(int ligaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/equipos/liga/$ligaId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Equipo.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar equipos por liga');
    }
  }

  // Listar equipos sin entrenador
  static Future<List<Equipo>> listarEquiposSinEntrenador() async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/equipos/sin-entrenador'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Equipo.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar equipos sin entrenador');
    }
  }

  // Actualizar equipo
  static Future<Equipo> actualizarEquipo(int id, Equipo equipo) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.put(
      Uri.parse('$baseUrl/equipos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(equipo.toJson()),
    );

    if (response.statusCode == 200) {
      return Equipo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar equipo');
    }
  }

  // Eliminar equipo
  static Future<void> eliminarEquipo(int id) async {
    final token = AutenticacionService.token;
    if (token == null) throw Exception('No autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/equipos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar equipo');
    }
  }

  // Contar jugadores del equipo
  static Future<int> contarJugadores(int equipoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/equipos/$equipoId/jugadores/count'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return 0;
    }
  }
}