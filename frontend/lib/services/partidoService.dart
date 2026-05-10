import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/partido.dart';
import '../models/role.dart';
import 'autenticacion_service.dart';
import 'loggerService.dart';

class PartidoService {
  static String get baseUrl => AppConfig.apiUrl;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = AutenticacionService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AutenticacionService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<dynamic>> buscarArbitros(String query) async {
    try {
      final response = await AppConfig.get('/usuarios/arbitros?search=$query');

      if (response == null) return [];

      final List<dynamic> data = response is List ? response : [];

      return data;
    } catch (e) {
      LoggerService.error('Error buscando árbitros', tag: 'PARTIDO', error: e);
      return [];
    }
  }

  static Future<List<Partido>> getProximosPartidosEquipo(int equipoId) async {
    try {
      final partidos = await getPartidosByEquipo(equipoId);
      final now = DateTime.now();

      DateTime? parseFecha(String fecha) {
        try {
          if (fecha.isEmpty) return null;

          if (fecha.contains('/')) {
            final parts = fecha.split('/');
            return DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }

          return DateTime.parse(fecha);
        } catch (_) {
          return null;
        }
      }

      return partidos
          .where((p) => p.estado != 'FINALIZADO')
          .where((p) {
        final fecha = parseFecha(p.fecha);
        return fecha != null && fecha.isAfter(now);
      })
          .toList()
        ..sort((a, b) {
          final fa = parseFecha(a.fecha);
          final fb = parseFecha(b.fecha);
          if (fa == null || fb == null) return 0;
          return fa.compareTo(fb);
        });

    } catch (e) {
      LoggerService.error(
        'Error cargando próximos partidos del equipo',
        tag: 'PARTIDO',
        error: e,
      );
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getEstadisticasPartido(int partidoId) async {
    try {
      final response = await AppConfig.get('/partidos/$partidoId/estadisticas');

      if (response == null) return null;

      return Map<String, dynamic>.from(response);
    } catch (e) {
      LoggerService.error('Error obteniendo estadísticas', tag: 'PARTIDO', error: e);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getDetallePartido(int partidoId) async {
    try {
      final response = await AppConfig.get('/partidos/$partidoId/detalle');

      if (response == null) return null;

      return Map<String, dynamic>.from(response);
    } catch (e) {
      LoggerService.error('Error detalle partido', tag: 'PARTIDO', error: e);
      return null;
    }
  }

  static Future<List<Partido>> getPartidosByJugador() async {
    try {
      final response = await AppConfig.get('/partidos/jugador/mis-partidos');
      final List<dynamic> data = response is List ? response : [];
      return data.map((json) => Partido.fromJson(json)).toList();
    } catch (e) {
      LoggerService.error('Error cargando partidos del jugador', tag: 'PARTIDO', error: e);
      return [];
    }
  }

  static Future<List<Partido>> getPartidosByArbitro() async {
    try {
      LoggerService.info('Obteniendo partidos del árbitro', tag: 'ARBITRO');

      final response = await AppConfig.get('/partidos/arbitro/mis-partidos');

      if (response == null) return [];

      final List<dynamic> data = response is List ? response : [];
      return data.map((json) => Partido.fromJson(json)).toList();
    } catch (e) {
      LoggerService.error('Error cargando partidos del árbitro', tag: 'ARBITRO', error: e);
      return [];
    }
  }

  static Future<List<Partido>> getPartidosByEquipo(int equipoId) async {
    try {
      final response = await AppConfig.get('/partidos/equipo/$equipoId');
      final List<dynamic> data = response is List ? response : [];
      return data.map((json) => Partido.fromJson(json)).toList();
    } catch (e) {
      LoggerService.error('Error cargando partidos del equipo', tag: 'PARTIDO', error: e);
      return [];
    }
  }

  static Future<List<Partido>> obtenerPartidosPorEquipoLocal(int equipoId) async {
    try {
      final partidos = await getPartidosByEquipo(equipoId);
      return partidos.where((p) => p.nombreLocal == equipoId).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Partido>> obtenerPartidosPorEquipoVisitante(int equipoId) async {
    try {
      final partidos = await getPartidosByEquipo(equipoId);
      return partidos.where((p) => p.nombreVisitante == equipoId).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Partido>> getPartidosEntrenador() async {
    try {
      final response = await AppConfig.get('/partidos/entrenador/mis-partidos');
      final List<dynamic> data = response is List ? response : [];
      return data.map((json) => Partido.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Partido?> getPartidoById(int partidoId) async {
    try {
      final response = await AppConfig.get('/partidos/$partidoId');
      return Partido.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Partido>> listarPartidos() async {
    try {
      final response = await AppConfig.get('/partidos/listar');

      if (response == null) return [];

      final List<dynamic> data = response is List ? response : [];

      return data.map((e) {
        final json = Map<String, dynamic>.from(e);
        return Partido.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> actualizarResultado(int partidoId, Map<String, dynamic> resultado) async {
    try {

      final usuario = AutenticacionService.usuarioActual;
      if (usuario?.role != Role.ADMIN) {
        throw Exception('No tienes permisos de administrador');
      }

      final tokenRefrescado = await AutenticacionService.refreshTokenUser();
      if (!tokenRefrescado) {
        throw Exception('Sesión expirada. Inicia sesión nuevamente.');
      }

      final data = {
        'puntosLocal': resultado['puntosLocal'] ?? 0,
        'puntosVisitante': resultado['puntosVisitante'] ?? 0,
        'estado': 'FINALIZADO',
      };

      final response = await http.put(
        Uri.parse('${AppConfig.apiUrl}/admin/partidos/$partidoId/resultado'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> eliminarPartido(int partidoId) async {
    try {
      await AppConfig.delete('/partidos/$partidoId');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> finalizarPartido(int partidoId, int puntosLocal, int puntosVisitante) async {
    try {

      final data = {
        'resultadoLocal': puntosLocal,
        'resultadoVisitante': puntosVisitante,
      };

      LoggerService.info('Finalizando partido $partidoId', tag: 'PARTIDO', data: data);

      await AppConfig.post('/partidos/$partidoId/finalizar', data: data);

      LoggerService.info('Partido finalizado correctamente', tag: 'PARTIDO');
    } catch (e) {
      LoggerService.error('Error finalizando partido $partidoId', tag: 'PARTIDO', error: e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> crearPartido(Map<String, dynamic> partidoData) async {
    return await AppConfig.post('/partidos/crear', data: partidoData);
  }

  static Future<List<Partido>> crearPartidosConJornadas(Map<String, dynamic> data) async {

    try {
      final response = await AppConfig.post('/partidos/crear-completo', data: data);
      final List<dynamic> dataList = response is List ? response : [];
      if (dataList.isNotEmpty) {
        return dataList.map((json) => Partido.fromJson(json)).toList();
      }
    } catch (_) {}

    final partidosCreados = <Partido>[];

    final ida = <String, dynamic>{
      'equipoLocalId': data['equipoLocalId'],
      'equipoVisitanteId': data['equipoVisitanteId'],
      'fecha': data['fechaIda'],
      'pabellon': data['pabellonIda'],
      'direccionPabellon': data['ubicacionIda'],
      'jornada': data['jornadaIda'],
      'ligaId': data['ligaId'],
      if (data['arbitroId'] != null) 'arbitroId': data['arbitroId'],
    };
    final r1 = await crearPartido(ida);
    partidosCreados.add(Partido.fromJson(r1));

    if (data['crearVuelta'] == true) {
      final vuelta = <String, dynamic>{
        'equipoLocalId': data['equipoVisitanteId'],
        'equipoVisitanteId': data['equipoLocalId'],
        'fecha': data['fechaVuelta'],
        'pabellon': data['pabellonVuelta'],
        'direccionPabellon': '',
        'jornada': data['jornadaVuelta'],
        'ligaId': data['ligaId'],
        if (data['arbitroId'] != null) 'arbitroId': data['arbitroId'],
      };
      final r2 = await crearPartido(vuelta);
      partidosCreados.add(Partido.fromJson(r2));
    }

    return partidosCreados;
  }

  static Future<void> asignarArbitro(int partidoId, int arbitroId) async {
    await AppConfig.put('/partidos/$partidoId/arbitro/$arbitroId');
  }

  static Future<List<Partido>> getPartidosByJornada(int jornada) async {
    final partidos = await listarPartidos();
    return partidos.where((p) => p.jornada == jornada).toList();
  }

  static Future<Map<int, List<Partido>>> getPartidosAgrupadosPorJornada() async {
    final partidos = await listarPartidos();
    final Map<int, List<Partido>> mapa = {};

    for (var partido in partidos) {
      int jornada = partido.jornada ?? 0;
      mapa.putIfAbsent(jornada, () => []).add(partido);
    }

    return mapa;
  }

  static Future<List<Partido>> listarPorLiga(int ligaId) async {
    try {
      final response = await AppConfig.get('/partidos/liga/$ligaId');
      final list = response is List ? response : [];
      return list.map<Partido>((j) => Partido.fromJson(j)).toList();
    } catch (_) {
      final todos = await listarPartidos();
      return todos.where((p) => p.ligaId == ligaId).toList();
    }
  }

  static Future<Partido> actualizarPartido(int partidoId, Map<String, dynamic> data) async {
  try {
  final response = await AppConfig.put('/partidos/$partidoId', data: data);

  if (response == null) {
  throw Exception('Error al actualizar el partido: respuesta vacía');
  }

  return Partido.fromJson(response);
  } catch (e) {
  throw Exception('Error al actualizar el partido: $e');
  }
  }

  static Future<Partido> editarPartido({
  required int partidoId,
  int? equipoLocalId,
  int? equipoVisitanteId,
  DateTime? fecha,
  String? pabellon,
  String? ubicacion,
  int? jornada,
  int? ligaId,
  }) async {
  try {
  final data = <String, dynamic>{};

  if (equipoLocalId != null) data['equipoLocalId'] = equipoLocalId;
  if (equipoVisitanteId != null) data['equipoVisitanteId'] = equipoVisitanteId;
  if (fecha != null) data['fecha'] = fecha.toIso8601String();
  if (pabellon != null) data['pabellon'] = pabellon;
  if (ubicacion != null) data['ubicacion'] = ubicacion;
  if (jornada != null) data['jornada'] = jornada;
  if (ligaId != null) data['ligaId'] = ligaId;

  final response = await AppConfig.put('/partidos/$partidoId', data: data);

  if (response == null) {
  throw Exception('Error al editar el partido: respuesta vacía');
  }

  return Partido.fromJson(response);
  } catch (e) {
  throw Exception('Error al editar el partido: $e');
  }
  }

  static Future<Partido> obtenerPartidoPorId(int partidoId) async {
  try {
  final response = await AppConfig.get('/partidos/$partidoId');

  if (response == null) {
  throw Exception('Partido no encontrado');
  }

  return Partido.fromJson(response);
  } catch (e) {
  throw Exception('Error al obtener el partido: $e');
  }
  }

}
