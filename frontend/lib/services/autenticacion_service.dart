// lib/services/autenticacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/DTOS/Login/loginRequest.dart';
import '../models/DTOS/Login/loginResponse.dart';
import '../models/DTOS/Registro/registroBaseDTO.dart';
import '../models/role.dart';
import '../models/usuario.dart';

class AutenticacionService {
  static String get baseUrl => AppConfig.apiUrl;

  static String? _token;
  static String? _refreshToken;
  static Usuario? _usuarioActual;

  static String? get token => _token;
  static String? get refreshToken => _refreshToken;
  static Usuario? get usuarioActual => _usuarioActual;

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
            print('✅ Sesión restaurada para: ${_usuarioActual?.username}');
          } catch (e) {
            print('Error restaurando usuario: $e');
            await _limpiarSesion();
          }
        }
      }
    } catch (e) {
      print('Error en init: $e');
    }
  }

  static Future<void> _limpiarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('usuario_actual');
    _token = null;
    _refreshToken = null;
    _usuarioActual = null;
  }

  // ============================================================
  // LOGIN CORREGIDO
  // ============================================================

  static Future<bool> login(String username, String password) async {
    try {
      print('📡 Intentando login para: $username');
      print('📡 URL: $baseUrl/usuarios/login');

      final request = LoginRequest(username: username, password: password);
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('❌ Respuesta vacía del servidor');
          return false;
        }

        final data = json.decode(response.body);

        // Validar que los datos necesarios existen
        if (data['token'] == null || data['refreshToken'] == null) {
          print('❌ Token o refreshToken no encontrados en respuesta');
          return false;
        }

        _token = data['token'];
        _refreshToken = data['refreshToken'];

        // Obtener username de la respuesta o decodificar del token
        String usernameActual = data['username'] ?? username;

        // Cargar usuario actual
        final cargado = await cargarUsuarioActual(usernameActual);

        if (cargado != null) {
          await _guardarSesion();
          print('✅ Login exitoso para: ${_usuarioActual?.username}');
          return true;
        } else {
          print('❌ No se pudo cargar el usuario');
          return false;
        }
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
        print('❌ Login error: $errorMsg');
        return false;
      }
    } catch (e) {
      print('❌ Login exception: $e');
      return false;
    }
  }

  // ============================================================
  // CARGAR USUARIO ACTUAL CORREGIDO
  // ============================================================

  static Future<Usuario?> cargarUsuarioActual(String username) async {
    if (_token == null) {
      print('No hay token para cargar usuario');
      return null;
    }

    try {
      final url = '$baseUrl/usuarios/perfil/$username';
      print('Cargando perfil desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      print('Perfil response status: ${response.statusCode}');
      print('Perfil response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('Respuesta de perfil vacía');
          return null;
        }

        final data = json.decode(response.body);
        print('Datos del perfil: $data');

        // Validar datos mínimos
        if (data['username'] == null) {
          print('Username no encontrado en respuesta');
          return null;
        }

        // Obtener el rol correctamente del backend
        final rolString = data['rol'] ?? 'USUARIO';
        print('Rol recibido del backend: $rolString');

        _usuarioActual = Usuario(
          id: data['id'],
          email: data['email'] ?? '',
          username: data['username'] ?? '',
          nombre: data['nombre'] ?? '',
          apellido: data['apellido'],
          licencia: data['licencia'],
          edad: data['edad'] ?? 0,
          role: Role.fromString(rolString),  // ← Usar el rol del backend
          verificado: data['verificado'] ?? false,
          bloqueado: data['bloqueado'] ?? false,
        );

        print('Usuario cargado: ${_usuarioActual?.username}, rol: ${_usuarioActual?.role.value}');
        return _usuarioActual;
      } else {
        print('Error cargando perfil: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception cargando perfil: $e');
      return null;
    }
  }

  // ============================================================
  // GUARDAR SESIÓN
  // ============================================================

  static Future<void> _guardarSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('auth_token', _token!);
      }
      if (_refreshToken != null) {
        await prefs.setString('refresh_token', _refreshToken!);
      }
      if (_usuarioActual != null) {
        await prefs.setString('usuario_actual', json.encode(_usuarioActual!.toJson()));
      }
      print('✅ Sesión guardada correctamente');
    } catch (e) {
      print('❌ Error guardando sesión: $e');
    }
  }

  // ============================================================
  // OBTENER USUARIO ACTUAL
  // ============================================================

  static Future<Usuario?> obtenerUsuarioActual() async {
    if (_usuarioActual != null) {
      print('📦 Usuario en memoria: ${_usuarioActual?.username}');
      return _usuarioActual;
    }

    // Intentar cargar de SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('usuario_actual');

      if (token != null && userJson != null && userJson.isNotEmpty) {
        _token = token;
        _usuarioActual = Usuario.fromJson(json.decode(userJson));
        print('📦 Usuario cargado de SharedPreferences: ${_usuarioActual?.username}');
        return _usuarioActual;
      }
    } catch (e) {
      print('Error cargando de SharedPreferences: $e');
    }

    print('❌ No hay usuario logueado');
    return null;
  }

  // ============================================================
  // VERIFICAR SESIÓN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    if (_token != null) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('usuario_actual');

      if (token != null && userJson != null && userJson.isNotEmpty) {
        _token = token;
        _usuarioActual = Usuario.fromJson(json.decode(userJson));
        return true;
      }
    } catch (e) {
      print('Error verificando sesión: $e');
    }

    return false;
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  static Future<void> cerrarSesion() async {
    try {
      if (_usuarioActual != null && _token != null) {
        await http.post(
          Uri.parse('$baseUrl/usuarios/logout?username=${_usuarioActual!.username}'),
          headers: _headers,
        ).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      print('Error en logout: $e');
    }

    await _limpiarSesion();
    print('✅ Sesión cerrada');
  }

  // ============================================================
  // REGISTRO
  // ============================================================

  static Future<bool> registrarUsuarioConDTO(RegistroBaseDTO dto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 Registro response: ${response.statusCode}');
      print('📡 Registro body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        String errorMsg = 'Error en el registro';
        try {
          if (response.body.isNotEmpty) {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? errorMsg;
          }
        } catch (e) {
          // Ignorar
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // VERIFICACIÓN
  // ============================================================

  static Future<LoginResponse?> verificarCodigo(String codigo, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/verificar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'codigo': codigo}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        _token = loginResponse.token;
        _refreshToken = loginResponse.refreshToken;
        await cargarUsuarioActual(loginResponse.username);
        await _guardarSesion();
        return loginResponse;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Error en la verificación');
      }
    } catch (e) {
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
}