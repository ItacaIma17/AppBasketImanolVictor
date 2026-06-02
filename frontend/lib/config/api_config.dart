import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../services/autenticacion_service.dart';
import '../services/loggerService.dart';

class AppConfig {
  // URL del backend en producción (Render)
  static const String _renderUrl = 'https://aragonbasket-backend.onrender.com';

  // En modo release apunta a Render, en debug a local
  static String get baseUrl {
    if (!kDebugMode) return _renderUrl;           // APK release → Render
    if (kIsWeb) return 'http://localhost:8080';   // Flutter web local
    if (Platform.isAndroid) return 'http://10.0.2.2:8080'; // emulador Android
    return 'http://localhost:8080';               // iOS / desktop local
  }

  static String get apiUrl => '$baseUrl/api';

  static String get registro => '$apiUrl/usuarios/registro';
  static String get login => '$apiUrl/usuarios/login';
  static String get verificar => '$apiUrl/usuarios/verificar';
  static String get reenviarCodigo => '$apiUrl/usuarios/reenviar-codigo';
  static String get refreshToken => '$apiUrl/usuarios/refresh-token';
  static String get logout => '$apiUrl/usuarios/logout';
  static String get cambiarPassword => '$apiUrl/usuarios/cambiar-password';

  static String perfil(String username) => '$apiUrl/usuarios/perfil/$username';
  static String seguirJugador(int id) => '$apiUrl/usuarios/seguirJugador/$id';
  static String seguirEquipo(int id) => '$apiUrl/usuarios/seguirEquipo/$id';
  static String actualizarPerfil(String username, String oldPassword,
      String newPassword) => '$apiUrl/usuarios/actualizar';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AutenticacionService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$apiUrl$endpoint');
      final headers = await _getHeaders();

      LoggerService.info('GET request: $url', tag: 'APP_CONFIG');

      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición GET'),
      );

      LoggerService.info('GET response: ${response.statusCode}', tag: 'APP_CONFIG');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permiso para acceder a este recurso.');
      } else if (response.statusCode == 404) {
        throw Exception('Recurso no encontrado.');
      } else {
        String errorMsg = 'Error en la petición GET';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          } catch (e) {}
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error en GET $endpoint', tag: 'APP_CONFIG', error: e);
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final url = Uri.parse('$apiUrl$endpoint');
      final headers = await _getHeaders();

      LoggerService.info('POST request: $url', tag: 'APP_CONFIG');

      final response = await http.post(
        url,
        headers: headers,
        body: data != null ? json.encode(data) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición POST'),
      );

      LoggerService.info('POST response: ${response.statusCode}', tag: 'APP_CONFIG');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        String errorMsg = 'Error en la petición POST';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          } catch (e) {}
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error en POST $endpoint', tag: 'APP_CONFIG', error: e);
      rethrow;
    }
  }

  static Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final url = Uri.parse('$apiUrl$endpoint');
      final headers = await _getHeaders();

      LoggerService.info('PUT request: $url', tag: 'APP_CONFIG');

      final response = await http.put(
        url,
        headers: headers,
        body: data != null ? json.encode(data) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición PUT'),
      );

      LoggerService.info('PUT response: ${response.statusCode}', tag: 'APP_CONFIG');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {

        String backendMsg = '';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            if (error is Map) {
              backendMsg = (error['message'] ??
                  error['error'] ??
                  error['reason'] ??
                  '')
                  .toString();
            }
          } catch (_) {

            backendMsg = response.body;
          }
        }
        final errorMsg = backendMsg.isEmpty
            ? 'Error PUT ${response.statusCode}'
            : 'Error PUT ${response.statusCode}: $backendMsg';
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error en PUT $endpoint', tag: 'APP_CONFIG', error: e);
      rethrow;
    }
  }

  static Future<void> delete(String endpoint) async {
    try {
      final url = Uri.parse('$apiUrl$endpoint');
      final headers = await _getHeaders();

      LoggerService.info('DELETE request: $url', tag: 'APP_CONFIG');

      final response = await http.delete(url, headers: headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición DELETE'),
      );

      LoggerService.info('DELETE response: ${response.statusCode}', tag: 'APP_CONFIG');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        String errorMsg = 'Error en la petición DELETE';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          } catch (e) {}
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error en DELETE $endpoint', tag: 'APP_CONFIG', error: e);
      rethrow;
    }
  }

}
