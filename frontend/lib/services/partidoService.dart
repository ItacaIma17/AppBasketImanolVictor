import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_appfede/config/api_config.dart';
import 'package:tfg_appfede/models/partido.dart';

class PartidoService {
  static String get baseUrl => AppConfig.apiUrl;

  /// Obtener todos los partidos
  static Future<List<Partido>> listarPartidos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/partidos/listar'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Partido.fromJson(data)).toList();
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error listando partidos: $e');
      return [];
    }
  }

  /// Obtener partidos por equipo local
  static Future<List<Partido>> obtenerPartidosPorEquipoLocal(int equipoId) async {
    try {
      final url = '$baseUrl/partidos/equipo-local/$equipoId';
      print('📡 Solicitando: GET $url');
      final response = await http.get(
        Uri.parse(url),
      );

      print('📊 Respuesta: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        print('✅ Partidos locales obtenidos: ${jsonData.length}');
        return jsonData.map((data) => Partido.fromJson(data)).toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listando partidos por equipo local: $e');
      return [];
    }
  }

  /// Obtener partidos por equipo visitante
  static Future<List<Partido>> obtenerPartidosPorEquipoVisitante(int equipoId) async {
    try {
      final url = '$baseUrl/partidos/equipo-visitante/$equipoId';
      print('📡 Solicitando: GET $url');
      final response = await http.get(
        Uri.parse(url),
      );

      print('📊 Respuesta: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        print('Partidos visitante obtenidos: ${jsonData.length}');
        return jsonData.map((data) => Partido.fromJson(data)).toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error listando partidos por equipo visitante: $e');
      return [];
    }
  }

  /// Obtener partidos por equipo (local y visitante)
  static Future<List<Partido>> obtenerPartidosPorEquipo(int equipoId) async {
    try {
      final locales = await obtenerPartidosPorEquipoLocal(equipoId);
      final visitantes = await obtenerPartidosPorEquipoVisitante(equipoId);
      
      // Combinar y ordenar por fecha
      final todos = [...locales, ...visitantes];
      todos.sort((a, b) => (b.fecha ?? '').compareTo(a.fecha ?? ''));
      
      return todos;
    } catch (e) {
      print('Error listando partidos por equipo: $e');
      return [];
    }
  }

  /// Obtener partido por ID
  static Future<Partido?> obtenerPartidoPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/partidos/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Partido.fromJson(data);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo partido por ID: $e');
      return null;
    }
  }

  /// Crear un nuevo partido
  static Future<Partido?> crearPartido(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/partidos/crear'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return Partido.fromJson(responseData);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creando partido: $e');
      return null;
    }
  }

  /// Actualizar resultado de un partido
  static Future<bool> actualizarResultado(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/partidos/$id/resultado'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error actualizando resultado: $e');
      return false;
    }
  }

  /// Eliminar un partido
  static Future<bool> eliminarPartido(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/partidos/$id'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error eliminando partido: $e');
      return false;
    }
  }
}