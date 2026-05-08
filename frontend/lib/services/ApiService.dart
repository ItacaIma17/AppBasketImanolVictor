// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg_appfede/config/api_config.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Método auxiliar para obtener headers
  static Future<Map<String, String>> getHeaders() async {
    final token = await AutenticacionService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      LoggerService.info('GET request: $url', tag: 'API');

      final response = await http.get(url, headers: _headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición GET'),
      );

      LoggerService.apiCall(
        'GET',
        url.toString(),
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        final dynamic data = json.decode(response.body);
        return data;
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
      LoggerService.error('Error en GET $endpoint', tag: 'API', error: e);
      rethrow;
    }
  }

  // POST request
  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      LoggerService.info('POST request: $url', tag: 'API');

      final response = await http.post(
        url,
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición POST'),
      );

      LoggerService.apiCall(
        'POST',
        url.toString(),
        statusCode: response.statusCode,
        requestBody: data,
        response: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return null;
        final dynamic responseData = json.decode(response.body);
        return responseData;
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
      LoggerService.error('Error en POST $endpoint', tag: 'API', error: e);
      rethrow;
    }
  }

  // PUT request
  static Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      LoggerService.info('PUT request: $url', tag: 'API');

      final response = await http.put(
        url,
        headers: _headers,
        body: data != null ? json.encode(data) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición PUT'),
      );

      LoggerService.apiCall(
        'PUT',
        url.toString(),
        statusCode: response.statusCode,
        requestBody: data,
        response: response.body,
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        final dynamic responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, inicia sesión nuevamente.');
      } else {
        String errorMsg = 'Error en la petición PUT';
        if (response.body.isNotEmpty) {
          try {
            final error = json.decode(response.body);
            errorMsg = error['message'] ?? error['error'] ?? errorMsg;
          } catch (e) {}
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      LoggerService.error('Error en PUT $endpoint', tag: 'API', error: e);
      rethrow;
    }
  }

  // DELETE request
  static Future<void> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      LoggerService.info('DELETE request: $url', tag: 'API');

      final response = await http.delete(url, headers: _headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Timeout en la petición DELETE'),
      );

      LoggerService.apiCall(
        'DELETE',
        url.toString(),
        statusCode: response.statusCode,
        response: response.body,
      );

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
      LoggerService.error('Error en DELETE $endpoint', tag: 'API', error: e);
      rethrow;
    }
  }
}