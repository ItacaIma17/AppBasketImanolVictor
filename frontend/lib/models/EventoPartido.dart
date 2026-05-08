class EventoPartido {
  final int? id;
  final int? jugadorId;
  final String nombreJugador;
  final String nombreEquipo;
  final int minuto;
  final String tipo;
  final String? descripcion;
  final int? puntos;

  EventoPartido({
    this.id,
    this.jugadorId,
    required this.nombreJugador,
    required this.nombreEquipo,
    required this.minuto,
    required this.tipo,
    this.descripcion,
    this.puntos,
  });
}