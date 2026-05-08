// lib/models/estadisticas_jugador.dart

class EstadisticasJugador {
  final int jugadorId;
  final String nombreJugador;
  final double promedioPuntos;
  final double promedioRebotes;
  final double promedioAsistencias;
  final double promedioRobos;
  final double promedioTapones;
  final int totalPartidos;
  final int totalPuntos;
  final int totalRebotes;
  final int totalAsistencias;
  final int totalRobos;
  final int totalTapones;
  final double eficiencia;
  final double porcentajeTirosCampo;
  final double porcentajeTriples;
  final double porcentajeLibres;

  EstadisticasJugador({
    required this.jugadorId,
    required this.nombreJugador,
    required this.promedioPuntos,
    required this.promedioRebotes,
    required this.promedioAsistencias,
    required this.promedioRobos,
    required this.promedioTapones,
    required this.totalPartidos,
    required this.totalPuntos,
    required this.totalRebotes,
    required this.totalAsistencias,
    required this.totalRobos,
    required this.totalTapones,
    required this.eficiencia,
    required this.porcentajeTirosCampo,
    required this.porcentajeTriples,
    required this.porcentajeLibres,
  });

  factory EstadisticasJugador.fromJson(Map<String, dynamic> json) {
    return EstadisticasJugador(
      jugadorId: json['jugadorId'] ?? 0,
      nombreJugador: json['nombreJugador'] ?? '',
      promedioPuntos: (json['promedioPuntos'] ?? 0).toDouble(),
      promedioRebotes: (json['promedioRebotes'] ?? 0).toDouble(),
      promedioAsistencias: (json['promedioAsistencias'] ?? 0).toDouble(),
      promedioRobos: (json['promedioRobos'] ?? 0).toDouble(),
      promedioTapones: (json['promedioTapones'] ?? 0).toDouble(),
      totalPartidos: json['totalPartidos'] ?? 0,
      totalPuntos: json['totalPuntos'] ?? 0,
      totalRebotes: json['totalRebotes'] ?? 0,
      totalAsistencias: json['totalAsistencias'] ?? 0,
      totalRobos: json['totalRobos'] ?? 0,
      totalTapones: json['totalTapones'] ?? 0,
      eficiencia: (json['eficiencia'] ?? 0).toDouble(),
      porcentajeTirosCampo: (json['porcentajeTirosCampo'] ?? 0).toDouble(),
      porcentajeTriples: (json['porcentajeTriples'] ?? 0).toDouble(),
      porcentajeLibres: (json['porcentajeLibres'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jugadorId': jugadorId,
      'nombreJugador': nombreJugador,
      'promedioPuntos': promedioPuntos,
      'promedioRebotes': promedioRebotes,
      'promedioAsistencias': promedioAsistencias,
      'promedioRobos': promedioRobos,
      'promedioTapones': promedioTapones,
      'totalPartidos': totalPartidos,
      'totalPuntos': totalPuntos,
      'totalRebotes': totalRebotes,
      'totalAsistencias': totalAsistencias,
      'totalRobos': totalRobos,
      'totalTapones': totalTapones,
      'eficiencia': eficiencia,
      'porcentajeTirosCampo': porcentajeTirosCampo,
      'porcentajeTriples': porcentajeTriples,
      'porcentajeLibres': porcentajeLibres,
    };
  }
}