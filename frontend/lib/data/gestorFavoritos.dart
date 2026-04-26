// lib/data/gestorFavoritos.dart
import 'package:shared_preferences/shared_preferences.dart';

class FavoritosManager {
  static final FavoritosManager _instance = FavoritosManager._internal();
  factory FavoritosManager() => _instance;
  FavoritosManager._internal();

  List<String> _equiposFavoritos = [];
  List<String> _jugadoresFavoritos = [];
  List<String> _categoriasFavoritas = [];

  List<String> get equiposFavoritos => _equiposFavoritos;
  List<String> get jugadoresFavoritos => _jugadoresFavoritos;
  List<String> get categoriasFavoritas => _categoriasFavoritas;

  Future<void> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    _equiposFavoritos = prefs.getStringList('equipos_favoritos') ?? [];
    _jugadoresFavoritos = prefs.getStringList('jugadores_favoritos') ?? [];
    _categoriasFavoritas = prefs.getStringList('categorias_favoritas') ?? [];
  }

  Future<void> _guardarEquipos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipos_favoritos', _equiposFavoritos);
  }

  Future<void> _guardarJugadores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('jugadores_favoritos', _jugadoresFavoritos);
  }

  Future<void> _guardarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categorias_favoritas', _categoriasFavoritas);
  }

  // ✅ Métodos para equipos
  void agregarEquipoFavorito(String nombreEquipo) {
    if (!_equiposFavoritos.contains(nombreEquipo)) {
      _equiposFavoritos.add(nombreEquipo);
      _guardarEquipos();
    }
  }

  void eliminarEquipoFavorito(String nombreEquipo) {
    _equiposFavoritos.remove(nombreEquipo);
    _guardarEquipos();
  }

  void toggleEquipoFavorito(String nombreEquipo) {
    if (_equiposFavoritos.contains(nombreEquipo)) {
      eliminarEquipoFavorito(nombreEquipo);
    } else {
      agregarEquipoFavorito(nombreEquipo);
    }
  }

  bool esEquipoFavorito(String nombreEquipo) {
    return _equiposFavoritos.contains(nombreEquipo);
  }

  // ✅ Métodos para jugadores
  void agregarJugadorFavorito(String nombreJugador) {
    if (!_jugadoresFavoritos.contains(nombreJugador)) {
      _jugadoresFavoritos.add(nombreJugador);
      _guardarJugadores();
    }
  }

  void eliminarJugadorFavorito(String nombreJugador) {
    _jugadoresFavoritos.remove(nombreJugador);
    _guardarJugadores();
  }

  void toggleJugadorFavorito(String nombreJugador) {
    if (_jugadoresFavoritos.contains(nombreJugador)) {
      eliminarJugadorFavorito(nombreJugador);
    } else {
      agregarJugadorFavorito(nombreJugador);
    }
  }

  bool esJugadorFavorito(String nombreJugador) {
    return _jugadoresFavoritos.contains(nombreJugador);
  }

  // ✅ Métodos para ligas/categorías
  void agregarCategoriaFavorita(String categoria) {
    if (!_categoriasFavoritas.contains(categoria)) {
      _categoriasFavoritas.add(categoria);
      _guardarCategorias();
    }
  }

  void eliminarCategoriaFavorita(String categoria) {
    _categoriasFavoritas.remove(categoria);
    _guardarCategorias();
  }

  void toggleCategoriaFavorita(String categoria) {
    if (_categoriasFavoritas.contains(categoria)) {
      eliminarCategoriaFavorita(categoria);
    } else {
      agregarCategoriaFavorita(categoria);
    }
  }

  bool esCategoriaFavorita(String categoria) {
    return _categoriasFavoritas.contains(categoria);
  }
}