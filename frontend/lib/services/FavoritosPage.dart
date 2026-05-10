import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritosService {
  static const String _KEY_FAVORITOS = 'favoritos_app';

  static const String TIPO_JUGADOR = 'jugador';
  static const String TIPO_EQUIPO = 'equipo';
  static const String TIPO_LIGA = 'liga';

  static Future<Map<String, dynamic>> _obtenerFavoritosMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritosStr = prefs.getString(_KEY_FAVORITOS);
      if (favoritosStr == null || favoritosStr.isEmpty) {
        return {};
      }
      return jsonDecode(favoritosStr);
    } catch (e) {
      print('Error cargando favoritos: $e');
      return {};
    }
  }

  static Future<void> _guardarFavoritosMap(Map<String, dynamic> favoritos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_KEY_FAVORITOS, jsonEncode(favoritos));
    } catch (e) {
      print('Error guardando favoritos: $e');
    }
  }

  static Future<void> agregarJugadorFavorito(int? jugadorId, String nombreCompleto, {String? equipoNombre}) async {
    if (jugadorId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_JUGADOR}_$jugadorId';

    favoritos[key] = {
      'tipo': TIPO_JUGADOR,
      'id': jugadorId,
      'nombre': nombreCompleto,
      'equipoNombre': equipoNombre,
      'fecha': DateTime.now().toIso8601String(),
    };

    await _guardarFavoritosMap(favoritos);
    print(' Jugador favorito agregado: $nombreCompleto');
  }

  static Future<void> eliminarJugadorFavorito(int? jugadorId) async {
    if (jugadorId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_JUGADOR}_$jugadorId';
    favoritos.remove(key);
    await _guardarFavoritosMap(favoritos);
    print(' Jugador favorito eliminado: $jugadorId');
  }

  static Future<bool> esJugadorFavorito(int? jugadorId) async {
    if (jugadorId == null) return false;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_JUGADOR}_$jugadorId';
    return favoritos.containsKey(key);
  }

  static Future<List<Map<String, dynamic>>> obtenerJugadoresFavoritos() async {
    final favoritos = await _obtenerFavoritosMap();
    final lista = <Map<String, dynamic>>[];

    favoritos.forEach((key, value) {
      if (value['tipo'] == TIPO_JUGADOR) {
        lista.add(Map<String, dynamic>.from(value));
      }
    });

    lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return lista;
  }

  static Future<void> agregarEquipoFavorito(int? equipoId, String nombreEquipo, {String? ligaNombre}) async {
    if (equipoId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_EQUIPO}_$equipoId';

    favoritos[key] = {
      'tipo': TIPO_EQUIPO,
      'id': equipoId,
      'nombre': nombreEquipo,
      'ligaNombre': ligaNombre,
      'fecha': DateTime.now().toIso8601String(),
    };

    await _guardarFavoritosMap(favoritos);
    print(' Equipo favorito agregado: $nombreEquipo');
  }

  static Future<void> eliminarEquipoFavorito(int? equipoId) async {
    if (equipoId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_EQUIPO}_$equipoId';
    favoritos.remove(key);
    await _guardarFavoritosMap(favoritos);
    print(' Equipo favorito eliminado: $equipoId');
  }

  static Future<bool> esEquipoFavorito(int? equipoId) async {
    if (equipoId == null) return false;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_EQUIPO}_$equipoId';
    return favoritos.containsKey(key);
  }

  static Future<List<Map<String, dynamic>>> obtenerEquiposFavoritos() async {
    final favoritos = await _obtenerFavoritosMap();
    final lista = <Map<String, dynamic>>[];

    favoritos.forEach((key, value) {
      if (value['tipo'] == TIPO_EQUIPO) {
        lista.add(Map<String, dynamic>.from(value));
      }
    });

    lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return lista;
  }

  static Future<void> agregarLigaFavorita(int? ligaId, String nombreLiga) async {
    if (ligaId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_LIGA}_$ligaId';

    favoritos[key] = {
      'tipo': TIPO_LIGA,
      'id': ligaId,
      'nombre': nombreLiga,
      'fecha': DateTime.now().toIso8601String(),
    };

    await _guardarFavoritosMap(favoritos);
    print(' Liga favorita agregada: $nombreLiga');
  }

  static Future<void> eliminarLigaFavorita(int? ligaId) async {
    if (ligaId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_LIGA}_$ligaId';
    favoritos.remove(key);
    await _guardarFavoritosMap(favoritos);
    print(' Liga favorita eliminada: $ligaId');
  }

  static Future<bool> esLigaFavorita(int? ligaId) async {
    if (ligaId == null) return false;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_LIGA}_$ligaId';
    return favoritos.containsKey(key);
  }

  static Future<List<Map<String, dynamic>>> obtenerLigasFavoritas() async {
    final favoritos = await _obtenerFavoritosMap();
    final lista = <Map<String, dynamic>>[];

    favoritos.forEach((key, value) {
      if (value['tipo'] == TIPO_LIGA) {
        lista.add(Map<String, dynamic>.from(value));
      }
    });

    lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return lista;
  }

  static Future<List<Map<String, dynamic>>> obtenerTodosFavoritos() async {
    final favoritos = await _obtenerFavoritosMap();
    final lista = <Map<String, dynamic>>[];

    favoritos.forEach((key, value) {
      lista.add(Map<String, dynamic>.from(value));
    });

    lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return lista;
  }

  static Future<int> contarFavoritos() async {
    final favoritos = await _obtenerFavoritosMap();
    return favoritos.length;
  }

  static Future<void> limpiarTodosFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_KEY_FAVORITOS);
    print(' Todos los favoritos han sido eliminados');
  }

  static Future<List<Map<String, dynamic>>> obtenerFavoritosPorTipo(String tipo) async {
    final favoritos = await _obtenerFavoritosMap();
    final lista = <Map<String, dynamic>>[];

    favoritos.forEach((key, value) {
      if (value['tipo'] == tipo) {
        lista.add(Map<String, dynamic>.from(value));
      }
    });

    lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return lista;
  }
}
