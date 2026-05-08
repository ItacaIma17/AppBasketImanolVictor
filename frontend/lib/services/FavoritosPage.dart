// lib/services/favoritos_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritosService {
  static const String _KEY_FAVORITOS = 'favoritos_app';

  // Tipos de favoritos
  static const String TIPO_JUGADOR = 'jugador';
  static const String TIPO_EQUIPO = 'equipo';
  static const String TIPO_LIGA = 'liga';

  // ============================================================
  // MÉTODOS PRINCIPALES
  // ============================================================

  /// Obtener todos los favoritos
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

  /// Guardar favoritos
  static Future<void> _guardarFavoritosMap(Map<String, dynamic> favoritos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_KEY_FAVORITOS, jsonEncode(favoritos));
    } catch (e) {
      print('Error guardando favoritos: $e');
    }
  }

  // ============================================================
  // MÉTODOS PARA JUGADORES
  // ============================================================

  /// Agregar jugador favorito
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
    print('✅ Jugador favorito agregado: $nombreCompleto');
  }

  /// Eliminar jugador favorito
  static Future<void> eliminarJugadorFavorito(int? jugadorId) async {
    if (jugadorId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_JUGADOR}_$jugadorId';
    favoritos.remove(key);
    await _guardarFavoritosMap(favoritos);
    print('❌ Jugador favorito eliminado: $jugadorId');
  }

  /// Verificar si es jugador favorito
  static Future<bool> esJugadorFavorito(int? jugadorId) async {
    if (jugadorId == null) return false;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_JUGADOR}_$jugadorId';
    return favoritos.containsKey(key);
  }

  /// Obtener todos los jugadores favoritos
  static Future<List<Map<String, dynamic>>> obtenerJugadoresFavoritos() async {
    final favoritos = await _obtenerFavoritosMap();
    final lista = <Map<String, dynamic>>[];

    favoritos.forEach((key, value) {
      if (value['tipo'] == TIPO_JUGADOR) {
        lista.add(Map<String, dynamic>.from(value));
      }
    });

    // Ordenar por fecha (más reciente primero)
    lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return lista;
  }

  // ============================================================
  // MÉTODOS PARA EQUIPOS
  // ============================================================

  /// Agregar equipo favorito
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
    print('✅ Equipo favorito agregado: $nombreEquipo');
  }

  /// Eliminar equipo favorito
  static Future<void> eliminarEquipoFavorito(int? equipoId) async {
    if (equipoId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_EQUIPO}_$equipoId';
    favoritos.remove(key);
    await _guardarFavoritosMap(favoritos);
    print('❌ Equipo favorito eliminado: $equipoId');
  }

  /// Verificar si es equipo favorito
  static Future<bool> esEquipoFavorito(int? equipoId) async {
    if (equipoId == null) return false;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_EQUIPO}_$equipoId';
    return favoritos.containsKey(key);
  }

  /// Obtener todos los equipos favoritos
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

  // ============================================================
  // MÉTODOS PARA LIGAS
  // ============================================================

  /// Agregar liga favorita
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
    print('✅ Liga favorita agregada: $nombreLiga');
  }

  /// Eliminar liga favorita
  static Future<void> eliminarLigaFavorita(int? ligaId) async {
    if (ligaId == null) return;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_LIGA}_$ligaId';
    favoritos.remove(key);
    await _guardarFavoritosMap(favoritos);
    print('❌ Liga favorita eliminada: $ligaId');
  }

  /// Verificar si es liga favorita
  static Future<bool> esLigaFavorita(int? ligaId) async {
    if (ligaId == null) return false;

    final favoritos = await _obtenerFavoritosMap();
    final key = '${TIPO_LIGA}_$ligaId';
    return favoritos.containsKey(key);
  }

  /// Obtener todas las ligas favoritas
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

  // ============================================================
  // MÉTODOS GENERALES
  // ============================================================

  /// Obtener todos los favoritos (sin filtrar por tipo)
  static Future<List<Map<String, dynamic>>> obtenerTodosFavoritos() async {
    final favoritos = await _obtenerFavoritosMap();
    final lista = <Map<String, dynamic>>[];

    favoritos.forEach((key, value) {
      lista.add(Map<String, dynamic>.from(value));
    });

    lista.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return lista;
  }

  /// Contar total de favoritos
  static Future<int> contarFavoritos() async {
    final favoritos = await _obtenerFavoritosMap();
    return favoritos.length;
  }

  /// Limpiar todos los favoritos (útil para pruebas)
  static Future<void> limpiarTodosFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_KEY_FAVORITOS);
    print('🗑️ Todos los favoritos han sido eliminados');
  }

  /// Obtener favoritos por tipo específico
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