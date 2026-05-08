// lib/services/autenticacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/DTOS/Login/loginRequest.dart';
import '../models/DTOS/Login/loginResponse.dart';
import '../models/DTOS/Registro/registroBaseDTO.dart';
import '../models/DTOS/updateUser/ActualizarUsuarioDTO.dart';
import '../models/role.dart';
import '../models/usuario.dart';
import '../models/entrenador.dart';
import '../models/jugador.dart';
import '../models/arbitro.dart';
import 'loggerService.dart';

class AutenticacionService {
  static String get baseUrl => AppConfig.apiUrl;

  static String? _token;
  static String? _refreshToken;
  static Usuario? _usuarioActual;
  static Entrenador? _entrenadorActual;
  static Jugador? _jugadorActual;
  static Arbitro? _arbitroActual;

  static String? get token => _token;
  static String? get refreshToken => _refreshToken;
  static Usuario? get usuarioActual => _usuarioActual;
  static Entrenador? get entrenadorActual => _entrenadorActual;
  static Jugador? get jugadorActual => _jugadorActual;
  static Arbitro? get arbitroActual => _arbitroActual;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      _refreshToken = prefs.getString('refresh_token');

      if (_token != null && _refreshToken != null) {
        final userJson = prefs.getString('usuario_actual');
        if (userJson != null && userJson.isNotEmpty) {
          try {
            _usuarioActual = Usuario.fromJson(json.decode(userJson));
            await cargarEntidadEspecifica(_usuarioActual!);
            LoggerService.info('Sesión restaurada para: ${_usuarioActual?.username}');
          } catch (e) {
            LoggerService.error('Error restaurando usuario: $e');
            await _limpiarSesion();
          }
        }
      }
    } catch (e) {
      LoggerService.error('Error en init: $e');
    }
  }

  // lib/services/autenticacion_service.dart - Añadir este método

  static Future<String?> getToken() async {
    if (_token != null) return _token;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        _token = token;
        return _token;
      }
    } catch (e) {
      LoggerService.error('Error obteniendo token: $e', tag: 'AUTH');
    }

    return null;
  }

  // En autenticacion_service.dart - Añadir método para verificar token

  static Future<bool> verificarTokenValido() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Verificar si el token ha expirado
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json.decode(
          utf8.decode(base64.decode(base64.normalize(parts[1])))
      );

      final exp = payload['exp'];
      if (exp != null) {
        final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        if (expDate.isBefore(DateTime.now())) {
          // Token expirado, intentar refrescar
          return await refreshTokenUser();
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

// También añade este método para obtener headers de forma asíncrona
  static Future<Map<String, String>> getHeadersAsync() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> cargarEntidadEspecifica(Usuario usuario) async {
    if (usuario.isEntrenador) {
      await cargarEntrenadorActual(usuario.username);
    } else if (usuario.isJugador) {
      await cargarJugadorActual(usuario.username);
    } else if (usuario.isArbitro) {
      await cargarArbitroActual(usuario.username);
    }
  }

  static Future<void> cargarEntrenadorActual(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entrenadores/username/$username'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _entrenadorActual = Entrenador.fromJson(json.decode(response.body));
        LoggerService.info('Entrenador cargado: ${_entrenadorActual?.nombre}');
      }
    } catch (e) {
      LoggerService.error('Error cargando entrenador: $e');
    }
  }

  static Future<void> cargarJugadorActual(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jugadores/username/$username'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _jugadorActual = Jugador.fromJson(json.decode(response.body));
        LoggerService.info('Jugador cargado: ${_jugadorActual?.nombre}');
      }
    } catch (e) {
      LoggerService.error('Error cargando jugador: $e');
    }
  }

  static Future<void> cargarArbitroActual(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arbitros/username/$username'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _arbitroActual = Arbitro.fromJson(json.decode(response.body));
        LoggerService.info('Árbitro cargado: ${_arbitroActual?.nombre}');
      }
    } catch (e) {
      LoggerService.error('Error cargando árbitro: $e');
    }
  }



  static Future<Map<String, dynamic>> actualizarPerfil({
    String? username,
    String? oldPassword,
    String? newPassword,
  }) async {
    if (_token == null) {
      throw Exception('No hay sesión iniciada');
    }

    try {
      final body = ActualizarUsuarioDTO(
        username: username,
        oldPassword: oldPassword,
        newPassword: newPassword,
      ).toJson();

      final bodyClean = Map.from(body)
        ..removeWhere((key, value) => value == null);

      LoggerService.info('Actualizando perfil', tag: 'PERFIL');

      final response = await http.put(
        Uri.parse('${AppConfig.apiUrl}/usuarios/actualizar'),
        headers: _headers,
        body: json.encode(bodyClean),
      ).timeout(const Duration(seconds: 30));

      LoggerService.apiCall('PUT', '${AppConfig.apiUrl}/usuarios/actualizar',
          statusCode: response.statusCode, response: response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Actualizar usuario en memoria si cambió username
        if (_usuarioActual != null && username != null && username.isNotEmpty) {
          _usuarioActual = _usuarioActual!.copyWith(username: username);
          await _guardarSesion();
        }

        return data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sesión expirada o no autorizado');
      } else {
        String errorMsg = 'Error al actualizar perfil';
        try {
          if (response.body.isNotEmpty) {
            final error = json.decode(response.body);
            errorMsg = error['error'] ?? error['message'] ?? errorMsg;
          }
        } catch (e) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error actualizando perfil', tag: 'PERFIL', error: e);
      rethrow;
    }
  }

  static Future<void> _guardarSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('auth_token', _token!);
      if (_refreshToken != null) await prefs.setString('refresh_token', _refreshToken!);
      if (_usuarioActual != null) {
        await prefs.setString('usuario_actual', json.encode(_usuarioActual!.toJson()));
      }
      LoggerService.info('Sesión guardada correctamente');
    } catch (e) {
      LoggerService.error('Error guardando sesión: $e');
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<bool> login(String username, String password) async {
    try {
      LoggerService.info('Intentando login para: $username');

      final request = LoginRequest(username: username, password: password);
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          LoggerService.error('Respuesta vacía del servidor');
          return false;
        }

        final data = json.decode(response.body);

        if (data['token'] == null || data['refreshToken'] == null) {
          LoggerService.error('Token o refreshToken no encontrados');
          return false;
        }

        _token = data['token'];
        _refreshToken = data['refreshToken'];
        String usernameActual = data['username'] ?? username;

        final cargado = await cargarUsuarioActual(usernameActual);

        if (cargado != null) {
          await cargarEntidadEspecifica(cargado);
          await _guardarSesion();
          LoggerService.info('Login exitoso para: ${_usuarioActual?.username}');
          return true;
        }
        return false;
      } else {
        String errorMsg = 'Error desconocido';
        try {
          if (response.body.isNotEmpty) {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? 'Credenciales incorrectas';
          }
        } catch (e) {
          errorMsg = 'Credenciales incorrectas';
        }
        LoggerService.error('Login error: $errorMsg');
        return false;
      }
    } catch (e) {
      LoggerService.error('Login exception: $e');
      return false;
    }
  }

  static Future<Usuario?> cargarUsuarioActual(String username) async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/perfil/$username'),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;

        final data = json.decode(response.body);
        String rolString = data['role'] ?? data['rol'] ?? 'USUARIO';
        final role = Role.fromString(rolString);

        _usuarioActual = Usuario(
          id: data['id'],
          email: data['email'] ?? '',
          username: data['username'] ?? '',
          nombre: data['nombre'] ?? '',
          apellido: data['apellido'],
          licencia: data['licencia'],
          edad: data['edad'] ?? 0,
          role: role,
          verificado: data['verificado'] ?? false,
          bloqueado: data['bloqueado'] ?? false,
        );

        return _usuarioActual;
      }
      return null;
    } catch (e) {
      LoggerService.error('Exception cargando perfil: $e');
      return null;
    }
  }

  static Future<bool> refreshTokenUser() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _refreshToken = data['refreshToken'];
        await _guardarSesion();
        LoggerService.info('Token refrescado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      LoggerService.error('Excepción refrescando token: $e');
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    if (_token != null) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('usuario_actual');
      if (token != null && userJson != null && userJson.isNotEmpty) {
        _token = token;
        _usuarioActual = Usuario.fromJson(json.decode(userJson));
        await cargarEntidadEspecifica(_usuarioActual!);
        return true;
      }
    } catch (e) {
      LoggerService.error('Error verificando sesión: $e');
    }
    return false;
  }

  static Future<Usuario?> obtenerUsuarioActual() async {
    if (_usuarioActual != null) return _usuarioActual;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('usuario_actual');
      if (token != null && userJson != null && userJson.isNotEmpty) {
        _token = token;
        _usuarioActual = Usuario.fromJson(json.decode(userJson));
        await cargarEntidadEspecifica(_usuarioActual!);
        return _usuarioActual;
      }
    } catch (e) {
      LoggerService.error('Error cargando de SharedPreferences: $e');
    }
    return null;
  }

  static Future<bool> registrarUsuarioConDTO(RegistroBaseDTO dto) async {
    try {
      final url = '$baseUrl/usuarios/registro';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 403) {
        throw Exception('Clave de administrador incorrecta');
      } else {
        String errorMsg = 'Error en el registro';
        try {
          if (response.body.isNotEmpty) {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          }
        } catch (e) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Excepción en registro: $e');
      rethrow;
    }
  }

  static Future<LoginResponse?> verificarCodigo(String codigo, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/verificar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'codigo': codigo}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        final data = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        _token = loginResponse.token;
        _refreshToken = loginResponse.refreshToken;
        await cargarUsuarioActual(loginResponse.username);
        await cargarEntidadEspecifica(_usuarioActual!);
        await _guardarSesion();
        return loginResponse;
      } else {
        String errorMsg = 'Error en la verificación';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          } catch (e) {}
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Excepción en verificación: $e');
      rethrow;
    }
  }

  static Future<void> reenviarCodigo(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/reenviar-codigo?email=$email'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error al reenviar código');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> cerrarSesion() async {
    try {
      // Intentar llamar al backend (pero no es crítico)
      if (_usuarioActual != null && _token != null) {
        try {
          // ✅ Crear headers SIN el token (opcional, o usar el token actual)
          final headers = {
            'Content-Type': 'application/json',
            // Opcional: añadir Authorization si el endpoint lo requiere
            // 'Authorization': 'Bearer $_token',
          };

          await http.post(
            Uri.parse('$baseUrl/usuarios/logout?username=${_usuarioActual!.username}'),
            headers: headers,
          ).timeout(const Duration(seconds: 3));
        } catch (e) {
          // Ignorar errores del backend, el logout local es lo importante
          print('Backend logout falló (ignorado): $e');
        }
      }
    } catch (e) {
      print('Error en logout: $e');
    } finally {
      // ✅ Siempre limpiar la sesión local
      await _limpiarSesion();
      LoggerService.info('Sesión cerrada');
    }
  }

  static Future<void> _limpiarSesion() async {
    _token = null;
    _refreshToken = null;
    _usuarioActual = null;

    // Limpiar almacenamiento persistente
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('usuario');

    LoggerService.info('Datos de sesión eliminados');
  }

  static bool isAdmin() {
    return _usuarioActual?.role == Role.ADMIN;
  }

  static Map<String, String> getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
}