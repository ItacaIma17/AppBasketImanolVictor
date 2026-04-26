import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/jugador.dart';

class JugadorService {
  static String get baseUrl => AppConfig.apiUrl;

  // Listar todos los jugadores
  static Future<List<Jugador>> listarJugadores() async {
    final response = await http.get(
      Uri.parse('$baseUrl/jugadores/listar'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Jugador.fromJson(item)).toList();
    } else {
      throw Exception('Error al listar jugadores');
    }
  }

  // Obtener jugadores por ID de equipo
  static Future<List<Jugador>> listarJugadoresPorEquipo(int equipoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/jugadores/equipo/$equipoId'),
      headers: {'Content-Type': 'application/json'},
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
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    return Jugador.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al obtener jugador');
  }
}
}