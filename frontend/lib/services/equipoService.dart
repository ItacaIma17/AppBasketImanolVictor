// lib/services/equipoService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/equipo.dart';
import '../models/jugador.dart';
import 'autenticacion_service.dart';

class EquipoService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ============================================================
  // LISTAR EQUIPOS
  // ============================================================

  // Listar todos los equipos
  static Future<List<Equipo>> listarEquipos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/listar'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      print('📡 Listar equipos response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar equipos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error listando equipos: $e');
      rethrow;
    }
  }

  // Listar equipos por liga
  static Future<List<Equipo>> listarEquiposPorLiga(int ligaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/liga/$ligaId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar equipos de la liga');
      }
    } catch (e) {
      print('❌ Error listando equipos por liga: $e');
      rethrow;
    }
  }

  // Listar equipos sin entrenador
  static Future<List<Equipo>> listarEquiposSinEntrenador() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/sin-entrenador'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      print('📡 Listar equipos sin entrenador response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar equipos sin entrenador');
      }
    } catch (e) {
      print('❌ Error listando equipos sin entrenador: $e');
      rethrow;
    }
  }

  // Listar equipos con solicitud pendiente (solo admin)
  static Future<List<Equipo>> listarEquiposConSolicitudPendiente() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/solicitudes-pendientes'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Equipo.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar solicitudes pendientes');
      }
    } catch (e) {
      print('❌ Error listando solicitudes pendientes: $e');
      rethrow;
    }
  }

  // ============================================================
  // CREAR EQUIPO
  // ============================================================

  // Crear nuevo equipo (solo admin)
  static Future<Equipo> crearEquipo(Map<String, dynamic> equipoData) async {
    try {
      print('📝 Creando equipo: $equipoData');

      final response = await http.post(
        Uri.parse('$baseUrl/equipos/crear'),
        headers: _headers,
        body: json.encode(equipoData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Crear equipo response: ${response.statusCode}');
      print('📡 Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al crear equipo');
      }
    } catch (e) {
      print('❌ Error creando equipo: $e');
      rethrow;
    }
  }

  // ============================================================
  // OBTENER EQUIPO
  // ============================================================

  // Obtener equipo por ID
  static Future<Equipo> obtenerEquipo(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Equipo no encontrado');
      }
    } catch (e) {
      print('❌ Error obteniendo equipo: $e');
      rethrow;
    }
  }

  // Obtener jugadores de equipo
  // lib/services/equipoService.dart

  // lib/services/equipoService.dart

  static Future<List<Jugador>> getJugadoresEquipo(int equipoId) async {
    try {
      final token = AutenticacionService.token;
      if (token == null) {
        print('❌ No hay token disponible');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$equipoId/jugadores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Jugadores encontrados en equipo $equipoId: ${data.length}');
        return data.map((j) => Jugador.fromJson(j)).toList();
      } else {
        print('❌ Error obteniendo jugadores: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo jugadores del equipo: $e');
      return [];
    }
  }

  // Obtener equipo por código de solicitud
  static Future<Equipo> obtenerEquipoPorCodigo(String codigo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/codigo/$codigo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Código de equipo inválido');
      }
    } catch (e) {
      print('❌ Error obteniendo equipo por código: $e');
      rethrow;
    }
  }

  // ============================================================
  // ACTUALIZAR EQUIPO
  // ============================================================

  // Actualizar equipo (solo admin)
  // lib/services/equipoService.dart

  // lib/services/equipoService.dart

  static Future<Equipo> actualizarEquipo(int id, Map<String, dynamic> equipoData) async {
    try {
      print('✏️ Actualizando equipo ID: $id');
      print('📝 Datos enviados: $equipoData');

      final response = await http.put(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
        body: json.encode(equipoData),
      ).timeout(const Duration(seconds: 30));

      print('📡 Status code: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar equipo');
      }
    } catch (e) {
      print('❌ Error actualizando equipo: $e');
      rethrow;
    }
  }

  // ============================================================
  // SOLICITUDES DE ENTRENADOR
  // ============================================================

  // Solicitar dirigir equipo (entrenador)
  static Future<void> solicitarDirigirEquipo(String codigoSolicitud) async {
    try {
      print('📨 Solicitando equipo con código: $codigoSolicitud');

      final response = await http.post(
        Uri.parse('$baseUrl/equipos/solicitar'),
        headers: _headers,
        body: json.encode({'codigoSolicitud': codigoSolicitud}),
      ).timeout(const Duration(seconds: 30));

      print('📡 Solicitar equipo response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al solicitar equipo');
      }
    } catch (e) {
      print('❌ Error solicitando equipo: $e');
      rethrow;
    }
  }

  // Aprobar/rechazar solicitud (solo admin)
  static Future<Equipo> aprobarSolicitud({
    required String codigoSolicitud,
    required int entrenadorId,
    required bool aprobar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipos/aprobar-solicitud'),
        headers: _headers,
        body: json.encode({
          'codigoSolicitud': codigoSolicitud,
          'entrenadorId': entrenadorId,
          'aprobar': aprobar,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Aprobar solicitud response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Equipo.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al procesar solicitud');
      }
    } catch (e) {
      print('❌ Error aprobando solicitud: $e');
      rethrow;
    }
  }

  // ============================================================
  // ELIMINAR EQUIPO
  // ============================================================

  // Eliminar equipo (solo admin)
  static Future<void> eliminarEquipo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      print('📡 Eliminar equipo response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar equipo');
      }
    } catch (e) {
      print('❌ Error eliminando equipo: $e');
      rethrow;
    }
  }

  // ============================================================
  // MÉTODOS ADICIONALES
  // ============================================================

  // Generar nuevo código de solicitud para un equipo (solo admin)
  static Future<String> regenerarCodigoSolicitud(int equipoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/equipos/$equipoId/regenerar-codigo'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['codigoSolicitud'];
      } else {
        throw Exception('Error al regenerar código');
      }
    } catch (e) {
      print('❌ Error regenerando código: $e');
      rethrow;
    }
  }

  // Obtener estadísticas del equipo
  static Future<Map<String, dynamic>> obtenerEstadisticasEquipo(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$equipoId/estadisticas'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar estadísticas');
      }
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      rethrow;
    }
  }

  // Obtener jugadores del equipo
  static Future<List<dynamic>> obtenerJugadoresEquipo(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$equipoId/jugadores'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar jugadores');
      }
    } catch (e) {
      print('❌ Error obteniendo jugadores: $e');
      rethrow;
    }
  }

  // Obtener próximos partidos del equipo
  static Future<List<dynamic>> obtenerProximosPartidos(int equipoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/equipos/$equipoId/proximos-partidos'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar próximos partidos');
      }
    } catch (e) {
      print('❌ Error obteniendo próximos partidos: $e');
      rethrow;
    }
  }
}