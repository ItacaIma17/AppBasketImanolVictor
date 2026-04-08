import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class Usuario {
  final String nombre;
  final String apellidos;
  final String email;
  final String password;
  final String rol;
  final String? licencia;
  final String username;
  final int? edad;

  Usuario({
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.password,
    required this.rol,
    required this.username,
    this.licencia,
    this.edad,
  });

  // Convertir a JSON para enviar al backend (Registro) - Usa 'apellido' singular
  Map<String, dynamic> toJsonRegistro() {
    return {
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
      'username': username,
      'edad': edad ?? 18,
    };
  }

  // Convertir a JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'password': password,
      'rol': rol,
      'username': username,
      'licencia': licencia,
      'edad': edad,
    };
  }

  // Construir desde JSON - Maneja 'apellido' del backend
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'] ?? '',
      apellidos: json['apellido'] ?? json['apellidos'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rol: json['rol'] ?? 'Aficionado',
      username: json['username'] ?? '',
      licencia: json['licencia'],
      edad: json['edad'],
    );
  }
}

class AutenticacionService {
  static const String _usuarioActualKey = 'usuario_actual';
  static const String _tokenKey = 'jwt_token';

  // Registrar un nuevo usuario
  static Future<bool> registrarUsuario(Usuario usuario) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registroEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(usuario.toJsonRegistro()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Usuario registrado exitosamente');
        return true;
      } else {
        print('Error en registro: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al registrar: $e');
      return false;
    }
  }

  // Iniciar sesión - IMPORTANTE: usa 'username', no 'email'
  static Future<bool> iniciarSesion(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Guardar token JWT
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString(_tokenKey, data['token']);
        }

        // Guardar usuario actual
        await prefs.setString(_usuarioActualKey, jsonEncode(data));

        print('Sesión iniciada correctamente');
        return true;
      } else {
        print('Error en login: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return false;
    }
  }

  // Obtener usuario actual desde SharedPreferences
  static Future<Usuario?> obtenerUsuarioActual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? usuarioJson = prefs.getString(_usuarioActualKey);

      if (usuarioJson == null) {
        return null;
      }

      return Usuario.fromJson(jsonDecode(usuarioJson));
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }

  // Obtener token JWT almacenado
  static Future<String?> obtenerToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  // Cerrar sesión
  static Future<void> cerrarSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usuarioActualKey);
      await prefs.remove(_tokenKey);
      print('Sesión cerrada');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Verificar si hay usuario actualmente logueado
  static Future<bool> tieneUsuarioActual() async {
    Usuario? usuario = await obtenerUsuarioActual();
    return usuario != null;
  }
}
