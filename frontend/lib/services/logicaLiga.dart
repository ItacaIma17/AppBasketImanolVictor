import 'package:tfg_appfede/services/LigaService.dart';


class LogicaLiga {
  static final LogicaLiga _instance = LogicaLiga._internal();
  factory LogicaLiga() => _instance;
  LogicaLiga._internal();

  List<Map<String, dynamic>> _ligas = [];

  /// Cargar todas las ligas de la base de datos
  Future<void> cargarLigas() async {
    try {
      _ligas = await LigaService.listarLigas();
    } catch (e) {
      print("Error cargando ligas: $e");
      _ligas = [];
    }
  }

  /// Obtener todas las ligas
  List<Map<String, dynamic>> get ligas => List.unmodifiable(_ligas);

  /// Buscar liga por nombre
  Map<String, dynamic>? buscarPorNombre(String nombre) {
    try {
      return _ligas.firstWhere(
        (l) => (l['nombreLiga'] ?? '').toString().toLowerCase() == nombre.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Buscar liga por ID
  Map<String, dynamic>? buscarPorId(int id) {
    try {
      return _ligas.firstWhere(
        (l) => l['id'] == id,
      );
    } catch (_) {
      return null;
    }
  }
}
