import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/entrenador.dart';
import '../models/entrenadorEquipo.dart';
import '../models/equipo.dart';
import '../models/jugador.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class EntrenadorService {
  static String get baseUrl => AppConfig.apiUrl;

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

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

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

  static Future<Map<String, dynamic>> obtenerMiEquipo() async {
    try {
      final token = AutenticacionService.token;
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/entrenadores/mi-equipo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('no_tiene_equipo');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al obtener equipo: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error obteniendo mi equipo', error: e);
      rethrow;
    }
  }

  static Future<List<Jugador>> getMisJugadores() async {
    try {
      final token = AutenticacionService.token;
      if (token == null) {
        LoggerService.warning('No hay token disponible');
        return [];
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/entrenadores/mis-jugadores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Jugador.fromJson(j)).toList();
      } else if (response.statusCode == 401) {
        LoggerService.warning('Token expirado o inválido, refrescando...');
        final refreshed = await AutenticacionService.refreshTokenUser();
        if (refreshed) {
          return await getMisJugadores();
        }
        return [];
      } else {
        LoggerService.warning('Error getMisJugadores: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      LoggerService.error('Error obteniendo jugadores', error: e);
      return [];
    }
  }

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

  static Future<List<Entrenador>> listarEntrenadoresSinEquipo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entrenadores/sin-equipo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Entrenador.fromJson(e)).toList();
      } else if (response.statusCode == 403) {
        LoggerService.warning('No autorizado para ver entrenadores');
        return [];
      } else {
        LoggerService.warning('Error al cargar entrenadores: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      LoggerService.error('Excepción al cargar entrenadores', error: e);
      return [];
    }
  }

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

  static Future<List<Equipo>> listarEquiposSinEntrenador() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/sin-entrenador'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      LoggerService.error('Excepción al cargar equipos', error: e);
      return [];
    }
  }

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
