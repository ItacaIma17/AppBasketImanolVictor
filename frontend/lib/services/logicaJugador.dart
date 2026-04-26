// lib/data/logicaJugador.dart
import 'package:tfg_appfede/models/jugador.dart';

class LogicaJugador {
  static final LogicaJugador _instance = LogicaJugador._internal();
  factory LogicaJugador() => _instance;
  LogicaJugador._internal();

  /// Lista de jugadores de ejemplo (para pruebas sin backend)
  final List<Jugador> _jugadoresEjemplo = [
    Jugador(
      id: 1,
      username: "pablo.perez",
      email: "pablo.perez@test.com",
      nombre: "Pablo",
      apellido: "Pérez",
      edad: 25,
      posicion: "Escolta",
      dorsal: 7,
      altura: 1.92,
      peso: 85,
      promedioPuntos: 18.6,
      promedioRebotes: 6.2,
      promedioAsistencias: 3.8,
      promedioRobos: 1.5,
      codigoJugador: "JUG-001",
      verificado: true,
      tieneEquipo: true,
      equipoId: 1,
      nombreEquipo: "Real Madrid",
    ),
    Jugador(
      id: 2,
      username: "adrian.fernandez",
      email: "adrian.fernandez@test.com",
      nombre: "Adrián",
      apellido: "Fernández",
      edad: 28,
      posicion: "Ala-Pívot",
      dorsal: 10,
      altura: 1.98,
      peso: 92,
      promedioPuntos: 15.4,
      promedioRebotes: 8.1,
      promedioAsistencias: 2.5,
      promedioRobos: 1.1,
      codigoJugador: "JUG-002",
      verificado: true,
      tieneEquipo: true,
      equipoId: 1,
      nombreEquipo: "Real Madrid",
    ),
    Jugador(
      id: 3,
      username: "miguel.torres",
      email: "miguel.torres@test.com",
      nombre: "Miguel",
      apellido: "Torres",
      edad: 22,
      posicion: "Base",
      dorsal: 4,
      altura: 1.85,
      peso: 78,
      promedioPuntos: 12.7,
      promedioRebotes: 4.3,
      promedioAsistencias: 5.9,
      promedioRobos: 0.9,
      codigoJugador: "JUG-003",
      verificado: true,
      tieneEquipo: false,
      equipoId: null,
      nombreEquipo: null,
    ),
  ];

  /// Obtener todos los jugadores de ejemplo
  List<Jugador> get jugadoresEjemplo => List.unmodifiable(_jugadoresEjemplo);

  /// Obtener todos los jugadores (podría venir del backend)
  List<Jugador> _jugadores = [];

  List<Jugador> get jugadores => List.unmodifiable(_jugadores);

  void setJugadores(List<Jugador> nuevosJugadores) {
    _jugadores = nuevosJugadores;
  }

  /// Buscar jugador por nombre completo
  Jugador? buscarPorNombre(String nombreCompleto) {
    try {
      return _jugadores.firstWhere(
            (j) => j.nombreCompleto.toLowerCase() == nombreCompleto.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Buscar jugador por ID
  Jugador? buscarPorId(int id) {
    try {
      return _jugadores.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Buscar jugador por dorsal
  Jugador? buscarPorDorsal(int dorsal) {
    try {
      return _jugadores.firstWhere((j) => j.dorsal == dorsal);
    } catch (_) {
      return null;
    }
  }

  /// Buscar jugadores por equipo
  List<Jugador> buscarPorEquipo(int equipoId) {
    return _jugadores.where((j) => j.equipoId == equipoId).toList();
  }

  /// Buscar jugadores por posición
  List<Jugador> buscarPorPosicion(String posicion) {
    return _jugadores.where((j) => j.posicion.toLowerCase() == posicion.toLowerCase()).toList();
  }

  /// Obtener los mejores anotadores (top N)
  List<Jugador> getMejoresAnotadores({int top = 5}) {
    final copia = List<Jugador>.from(_jugadores);
    copia.sort((a, b) => b.promedioPuntos.compareTo(a.promedioPuntos));
    return copia.take(top).toList();
  }

  /// Obtener los mejores reboteadores (top N)
  List<Jugador> getMejoresReboteadores({int top = 5}) {
    final copia = List<Jugador>.from(_jugadores);
    copia.sort((a, b) => b.promedioRebotes.compareTo(a.promedioRebotes));
    return copia.take(top).toList();
  }

  /// Obtener los mejores asistentes (top N)
  List<Jugador> getMejoresAsistentes({int top = 5}) {
    final copia = List<Jugador>.from(_jugadores);
    copia.sort((a, b) => b.promedioAsistencias.compareTo(a.promedioAsistencias));
    return copia.take(top).toList();
  }

  /// Limpiar lista
  void limpiar() {
    _jugadores.clear();
  }

  /// Agregar un jugador
  void agregarJugador(Jugador jugador) {
    _jugadores.add(jugador);
  }

  /// Eliminar un jugador por ID
  void eliminarJugador(int id) {
    _jugadores.removeWhere((j) => j.id == id);
  }
}