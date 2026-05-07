import 'package:shared_preferences/shared_preferences.dart';

class FavoritosManager {
  static final FavoritosManager _instance = FavoritosManager._internal();
  factory FavoritosManager() => _instance;
  FavoritosManager._internal();

  List<int> _equiposFavoritos = [];
  List<int> _jugadoresFavoritos = [];
  List<String> _categoriasFavoritas = [];

  List<int> get equiposFavoritos => _equiposFavoritos;
  List<int> get jugadoresFavoritos => _jugadoresFavoritos;
  List<String> get categoriasFavoritas => _categoriasFavoritas;

  Future<void> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    _equiposFavoritos = (prefs.getStringList('equipos_favoritos') ?? [])
        .map((e) => int.parse(e)).toList();
    _jugadoresFavoritos = (prefs.getStringList('jugadores_favoritos') ?? [])
        .map((e) => int.parse(e)).toList();
    _categoriasFavoritas = prefs.getStringList('categorias_favoritas') ?? [];
  }

  Future<void> _guardarEquipos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('equipos_favoritos',
        _equiposFavoritos.map((e) => e.toString()).toList());
  }

  Future<void> _guardarJugadores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('jugadores_favoritos',
        _jugadoresFavoritos.map((e) => e.toString()).toList());
  }

  Future<void> _guardarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categorias_favoritas', _categoriasFavoritas);
  }

  // ── EQUIPOS ──────────────────────────────────────────
  void agregarEquipoFavorito(int id) {
    if (!_equiposFavoritos.contains(id)) {
      _equiposFavoritos.add(id);
      _guardarEquipos();
    }
  }

  void eliminarEquipoFavorito(int id) {
    _equiposFavoritos.remove(id);
    _guardarEquipos();
  }

  void toggleEquipoFavorito(int id) {
    if (_equiposFavoritos.contains(id)) {
      eliminarEquipoFavorito(id);
    } else {
      agregarEquipoFavorito(id);
    }
  }

  bool esEquipoFavorito(int id) => _equiposFavoritos.contains(id);

  // ── JUGADORES ─────────────────────────────────────────
  void agregarJugadorFavorito(int id) {
    if (!_jugadoresFavoritos.contains(id)) {
      _jugadoresFavoritos.add(id);
      _guardarJugadores();
    }
  }

  void eliminarJugadorFavorito(int id) {
    _jugadoresFavoritos.remove(id);
    _guardarJugadores();
  }

  void toggleJugadorFavorito(int id) {
    if (_jugadoresFavoritos.contains(id)) {
      eliminarJugadorFavorito(id);
    } else {
      agregarJugadorFavorito(id);
    }
  }

  bool esJugadorFavorito(int id) => _jugadoresFavoritos.contains(id);

  // ── LIGAS/CATEGORÍAS ──────────────────────────────────
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

  bool esCategoriaFavorita(String categoria) =>
      _categoriasFavoritas.contains(categoria);
}