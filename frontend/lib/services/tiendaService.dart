import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import 'autenticacion_service.dart';

class TiendaService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  static Future<List<Producto>> listarProductos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/productos/listar'),
      headers: _headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Producto.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar productos: ${response.statusCode}');
  }

  static Future<Pedido> crearPedido(List<Map<String, dynamic>> items) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tienda/pedido'),
      headers: _headers,
      body: json.encode({'items': items}),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Pedido.fromJson(json.decode(response.body));
    }
    String msg = 'Error al crear pedido';
    if (response.body.isNotEmpty) {
      try {
        final e = json.decode(response.body);
        msg = e['message'] ?? e['error'] ?? msg;
      } catch (_) {}
    }
    throw Exception(msg);
  }

  static Future<List<Pedido>> misPedidos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tienda/mis-pedidos'),
      headers: _headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Pedido.fromJson(j as Map<String, dynamic>)).toList();
    }
    throw Exception('Error al cargar pedidos: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> procesarPago(Map<String, dynamic> request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pagos/procesar'),
      headers: _headers,
      body: json.encode(request),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    String msg = 'Error al procesar el pago';
    if (response.body.isNotEmpty) {
      try {
        final e = json.decode(response.body);
        msg = e['message'] ?? e['error'] ?? msg;
      } catch (_) {}
    }
    throw Exception(msg);
  }

  static Future<Pedido> cancelarPedido(int pedidoId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tienda/pedido/$pedidoId/cancelar'),
      headers: _headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return Pedido.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cancelar pedido: ${response.statusCode}');
  }
}