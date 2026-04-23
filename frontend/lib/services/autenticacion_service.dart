// lib/services/autenticacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/DTOS/Login/loginRequest.dart';
import '../models/DTOS/Login/loginResponse.dart';
import '../models/DTOS/Registro/registroBaseDTO.dart';
import '../models/DTOS/updateUser/ActualizarUsuarioDTO.dart';
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

  // En autenticacion_service.dart
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
        print('✅ Token refrescado exitosamente');
        return true;
      } else {
        print('❌ Error refrescando token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Excepción refrescando token: $e');
      return false;
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

        if (data['username'] == null) {
          print('Username no encontrado en respuesta');
          return null;
        }

        // Obtener el rol del backend
        final rolString = data['rol'] ?? 'USUARIO';
        print('Rol recibido del backend: $rolString');

        // ✅ USAR fromString PARA CONVERTIR EL STRING A ENUM
        final role = Role.fromString(rolString);
        print('Role convertido: ${role.displayName}');

        _usuarioActual = Usuario(
          id: data['id'],
          email: data['email'] ?? '',
          username: data['username'] ?? '',
          nombre: data['nombre'] ?? '',
          apellido: data['apellido'],
          licencia: data['licencia'],
          edad: data['edad'] ?? 0,
          role: role,  // ← Aquí usas el Role convertido
          verificado: data['verificado'] ?? false,
          bloqueado: data['bloqueado'] ?? false,
        );

        print('Usuario cargado: ${_usuarioActual?.username}, rol: ${_usuarioActual?.role.displayName}');
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

  // lib/services/autenticacion_service.dart
// Añadir este método en la clase AutenticacionService

  // autenticacion_service.dart - método actualizarPerfil mejorado
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

      print('═══════════════════════════════════════════');
      print('🔑 Token: ${_token!.substring(0, _token!.length > 20 ? 20 : _token!.length)}...');
      print('📏 Longitud token: ${_token!.length}');
      print('📦 Body a enviar: $bodyClean');
      print('🌐 URL: ${AppConfig.apiUrl}/usuarios/actualizar');
      print('═══════════════════════════════════════════');

      final response = await http.put(
        Uri.parse('${AppConfig.apiUrl}/usuarios/actualizar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
        body: json.encode(bodyClean),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Actualizar usuario en memoria si cambió username
        if (_usuarioActual != null && username != null && username.isNotEmpty) {
          _usuarioActual = _usuarioActual!.copyWith(username: username);
          await _guardarSesion();
        }

        return data;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sesión expirada o no autorizado. Por favor, inicia sesión nuevamente.');
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
      print('❌ Error actualizando perfil: $e');
      rethrow;
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
      // ✅ CORREGIDO: Usar el endpoint correcto
      final url = '$baseUrl/usuarios/registro';  // ← Cambiado de 'auth/register' a 'usuarios/registro'
      print('📝 Enviando registro a: $url');
      print('📝 Datos: ${dto.toJson()}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📡 Registro response: ${response.statusCode}');
      print('📡 Registro body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registro exitoso');
        return true;
      } else if (response.statusCode == 403) {
        print('❌ Clave de administrador incorrecta');
        throw Exception('Clave de administrador incorrecta');
      } else {
        String errorMsg = 'Error en el registro';
        try {
          if (response.body.isNotEmpty) {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          }
        } catch (e) {
          print('Error parseando respuesta: $e');
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Excepción en registro: $e');
      rethrow;
    }
  }

  // ============================================================
  // VERIFICACIÓN
  // ============================================================

  static Future<LoginResponse?> verificarCodigo(String codigo, String email) async {
    try {
      // ✅ Usar el endpoint correcto para verificación
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios/verificar'),  // Este parece correcto según logs
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,     // ← Asegurar que envía el email
          'codigo': codigo,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Verificación response: ${response.statusCode}');
      print('📡 Verificación body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('✅ Verificación exitosa sin contenido');
          return null;
        }

        final data = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        _token = loginResponse.token;
        _refreshToken = loginResponse.refreshToken;
        await cargarUsuarioActual(loginResponse.username);
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
      print('❌ Excepción en verificación: $e');
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