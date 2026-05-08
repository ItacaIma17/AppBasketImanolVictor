// lib/services/adminService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_appfede/config/api_config.dart';
import 'package:tfg_appfede/models/usuario.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class AdminService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  static Future<Map<String, dynamic>> getEstadisticasGenerales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/estadisticas'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return _estadisticasVacias();
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas', tag: 'ADMIN', error: e);
      return _estadisticasVacias();
    }
  }

  static Map<String, dynamic> _estadisticasVacias() => {
    'totalUsuarios': 0,
    'totalEntrenadores': 0,
    'totalJugadores': 0,
    'totalArbitros': 0,
    'totalEquipos': 0,
    'totalLigas': 0,
    'totalPartidos': 0,
    'partidosHoy': 0,
    'partidosFinalizados': 0,
    'partidosProgramados': 0,
    'usuariosActivos': 0,
    'usuariosBloqueados': 0,
  };

  // ============================================================
  // USUARIOS
  // ============================================================

  /// Listar todos los usuarios
  static Future<List<Usuario>> listarTodosUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/usuarios'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('GET', '$baseUrl/admin/usuarios',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al listar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando usuarios', tag: 'ADMIN', error: e);
      return [];
    }
  }

  /// Listar usuarios por rol
  static Future<List<Usuario>> listarUsuariosPorRol(String rol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/usuarios/rol/$rol'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al listar usuarios por rol: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando usuarios por rol', tag: 'ADMIN', error: e);
      return [];
    }
  }

  /// Listar usuarios pendientes de verificación
  static Future<List<Usuario>> listarUsuariosPendientes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/usuarios/pendientes'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al listar usuarios pendientes: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando usuarios pendientes', tag: 'ADMIN', error: e);
      return [];
    }
  }

  /// Listar usuarios bloqueados
  static Future<List<Usuario>> listarUsuariosBloqueados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/usuarios/bloqueados'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al listar usuarios bloqueados: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error listando usuarios bloqueados', tag: 'ADMIN', error: e);
      return [];
    }
  }

  /// Bloquear un usuario
  static Future<bool> bloquearUsuario(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/usuarios/$userId/bloquear'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        LoggerService.info('Usuario $userId bloqueado', tag: 'ADMIN');
        return true;
      } else {
        throw Exception('Error al bloquear usuario: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error bloqueando usuario', tag: 'ADMIN', error: e);
      return false;
    }
  }

  /// Desbloquear un usuario
  static Future<bool> desbloquearUsuario(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/usuarios/$userId/desbloquear'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        LoggerService.info('Usuario $userId desbloqueado', tag: 'ADMIN');
        return true;
      } else {
        throw Exception('Error al desbloquear usuario: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error desbloqueando usuario', tag: 'ADMIN', error: e);
      return false;
    }
  }

  /// Eliminar un usuario
  static Future<bool> eliminarUsuario(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/usuarios/$userId'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 204 || response.statusCode == 200) {
        LoggerService.info('Usuario $userId eliminado', tag: 'ADMIN');
        return true;
      } else {
        throw Exception('Error al eliminar usuario: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('Error eliminando usuario', tag: 'ADMIN', error: e);
      return false;
    }
  }

  // ============================================================
  // ACTIVIDAD RECIENTE
  // ============================================================

  /// Obtener actividad reciente del sistema
  static Future<List<Map<String, dynamic>>> getActividadReciente() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/actividad-reciente'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      LoggerService.error('Error obteniendo actividad reciente', tag: 'ADMIN', error: e);
      return [];
    }
  }

  // ============================================================
  // ESTADÍSTICAS AVANZADAS
  // ============================================================

  /// Obtener estadísticas de usuarios (gráficos)
  static Future<Map<String, dynamic>> getEstadisticasUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/estadisticas/usuarios'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'total': 0,
        'porRol': {},
        'activos': 0,
        'bloqueados': 0,
        'pendientes': 0,
      };
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas de usuarios', tag: 'ADMIN', error: e);
      return {
        'total': 0,
        'porRol': {},
        'activos': 0,
        'bloqueados': 0,
        'pendientes': 0,
      };
    }
  }
}