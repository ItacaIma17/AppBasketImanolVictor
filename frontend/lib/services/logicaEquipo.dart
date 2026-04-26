import 'package:tfg_appfede/models/equipo.dart';
import 'package:tfg_appfede/services/equipoService.dart';


class LogicaEquipo {
  static final LogicaEquipo _instance = LogicaEquipo._internal();
  factory LogicaEquipo() => _instance;
  LogicaEquipo._internal();

  List<Equipo> _equipos = [];
  bool _cargado = false;

  /// Cargar todos los equipos de la base de datos
  Future<void> cargarEquipos() async {
    if (_cargado) return; // Si ya están cargados, no cargar de nuevo
    
    try {
      _equipos = await EquipoService.listarEquipos();
      _cargado = true;
    } catch (e) {
      print("Error cargando equipos: $e");
      _equipos = [];
    }
  }

  /// Obtener todos los equipos
  List<Equipo> get equipos => List.unmodifiable(_equipos);

  /// Obtener equipos por ID de liga
  List<Equipo> obtenerEquiposPorLiga(int ligaId) {
    return _equipos.where((equipo) {
      // Comprobar ambos campos: ligaId e id_liga
      final equipoLigaId = equipo.ligaId ?? 0;
      final equipoIdLiga = equipo.id_liga ?? 0;
      return equipoLigaId == ligaId || equipoIdLiga == ligaId;
    }).toList();
  }

  /// Buscar equipo por nombre
  Equipo? buscarPorNombre(String nombre) {
    try {
      return _equipos.firstWhere(
        (e) => e.nombre.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Buscar equipo por ID
  Equipo? buscarPorId(int id) {
    try {
      return _equipos.firstWhere(
        (e) => e.id == id,
      );
    } catch (_) {
      return null;
    }
  }
}
