class Jugador {
  // Campos principales
  final int? id;
  final String username;
  final String email;
  final String nombre;
  final String? apellido;
  final int edad;
  final String posicion;
  final int dorsal;
  final double altura;
  final double peso;
  final int puntosTotales;
  final int rebotesTotales;
  final int asistenciasTotales;
  final int robosTotales;
  final int partidosJugados;
  final String? codigoJugador;
  final bool verificado;
  final bool tieneEquipo;
  final int? equipoId;
  final String? nombreEquipo;

  Jugador({
    this.id,
    required this.username,
    required this.email,
    required this.nombre,
    this.apellido,
    required this.edad,
    required this.posicion,
    required this.dorsal,
    required this.altura,
    required this.peso,

    // Nuevos campos
    required this.puntosTotales,
    required this.rebotesTotales,
    required this.asistenciasTotales,
    required this.robosTotales,
    required this.partidosJugados,

    this.codigoJugador,
    this.verificado = false,
    this.tieneEquipo = false,
    this.equipoId,
    this.nombreEquipo,
  });

  // ============================================================
  // GETTERS
  // ============================================================

  String get nombreCompleto => '$nombre ${apellido ?? ''}'.trim();

  String get iniciales {
    String primera = nombre.isNotEmpty ? nombre[0] : '';
    String segunda = apellido != null && apellido!.isNotEmpty ? apellido![0] : '';
    return '$primera$segunda'.toUpperCase();
  }

  String get alturaFormateada => '${altura.toStringAsFixed(2)}m';
  String get pesoFormateado => '${peso.toStringAsFixed(0)}kg';

  double get promedioPuntos =>
      partidosJugados == 0 ? 0 : puntosTotales / partidosJugados;

  double get promedioRebotes =>
      partidosJugados == 0 ? 0 : rebotesTotales / partidosJugados;

  double get promedioAsistencias =>
      partidosJugados == 0 ? 0 : asistenciasTotales / partidosJugados;

  double get promedioRobos =>
      partidosJugados == 0 ? 0 : robosTotales / partidosJugados;

  // ============================================================
  // FROM JSON
  // ============================================================

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      edad: json['edad'] ?? 0,
      posicion: json['posicion'] ?? '',
      dorsal: json['dorsal'] ?? 0,
      altura: (json['altura'] ?? 0.0).toDouble(),
      peso: (json['peso'] ?? 0.0).toDouble(),

      // Nuevos campos
      puntosTotales: json['puntosTotales'] ?? 0,
      rebotesTotales: json['rebotesTotales'] ?? 0,
      asistenciasTotales: json['asistenciasTotales'] ?? 0,
      robosTotales: json['robosTotales'] ?? 0,
      partidosJugados: json['partidosJugados'] ?? 0,

      codigoJugador: json['codigoJugador'],
      verificado: json['verificado'] ?? false,
      tieneEquipo: json['tieneEquipo'] ?? false,
      equipoId: json['equipoId'],
      nombreEquipo: json['nombreEquipo'],
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'posicion': posicion,
      'dorsal': dorsal,
      'altura': altura,
      'peso': peso,
      'puntosTotales': puntosTotales,
      'rebotesTotales': rebotesTotales,
      'asistenciasTotales': asistenciasTotales,
      'robosTotales': robosTotales,
      'partidosJugados': partidosJugados,
      'codigoJugador': codigoJugador,
      'verificado': verificado,
      'tieneEquipo': tieneEquipo,
      'equipoId': equipoId,
      'nombreEquipo': nombreEquipo,
    };
  }
}
