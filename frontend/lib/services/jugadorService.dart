import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/jugador.dart';
import 'autenticacion_service.dart';

class JugadorService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Listar todos los jugadores
  static Future<List<Jugador>> listarJugadores() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/listar'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final jugadores = <Jugador>[];
        for (int i = 0; i < data.length; i++) {
          try {
            jugadores.add(Jugador.fromJson(data[i]));
          } catch (e) {
            print('❌ Error parseando jugador[$i]: $e');
          }
        }
        return jugadores;
      } else {
        throw Exception('Error al listar jugadores: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error listando jugadores: $e');
      rethrow;
    }
  }

  // Obtener jugadores por ID de equipo
  static Future<List<Jugador>> listarJugadoresPorEquipo(int equipoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jugadores/equipo/$equipoId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Jugador.fromJson(item)).toList();
    } else {
      throw Exception('Error al listar jugadores del equipo');
    }
  }

  // Obtener jugador por ID
  static Future<Jugador> obtenerJugadorPorId(int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/jugadores/$id'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    return Jugador.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al obtener jugador');
  }
}
}