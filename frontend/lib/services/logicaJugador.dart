import 'package:tfg_appfede/models/jugador.dart';
import 'package:tfg_appfede/services/jugadorService.dart';

class LogicaJugador {
  static final LogicaJugador _instance = LogicaJugador._internal();
  factory LogicaJugador() => _instance;
  LogicaJugador._internal();

  List<Jugador> _jugadores = [];
  bool _cargado = false;

  /// Cargar todos los jugadores de la base de datos
  Future<void> cargarJugadores() async {
    if (_cargado) return; // Si ya están cargados, no cargar de nuevo
    
    try {
      _jugadores = await JugadorService.listarJugadores();
      _cargado = true;
    } catch (e) {
      print("Error cargando jugadores: $e");
      _jugadores = [];
    }
  }

  /// Obtener todos los jugadores
  List<Jugador> get jugadores => List.unmodifiable(_jugadores);

  /// Obtener jugadores por ID de equipo
  List<Jugador> obtenerJugadoresPorEquipo(int equipoId) {
    return _jugadores.where((jugador) {
      // Convertir id_equipo (String) a int para comparar con equipoId (int)
      final idEquipoInt = int.tryParse(jugador.id_equipo) ?? -1;
      return idEquipoInt == equipoId;
    }).toList();
  }

  /// Buscar jugador por nombre completo
  Jugador? buscarPorNombre(String nombreCompleto) {
    try {
      return _jugadores.firstWhere(
        (j) => "${j.nombre} ${j.apellido}".toLowerCase() == nombreCompleto.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Buscar jugador por ID
  Jugador? buscarPorId(int id) {
    try {
      return _jugadores.firstWhere(
        (j) => j.id_equipo == id,
      );
    } catch (_) {
      return null;
    }
  }
}
