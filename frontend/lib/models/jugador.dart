class Jugador {

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

  factory Jugador.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? _parseIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Jugador(
      id: _parseIntNullable(json['id']),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      edad: _parseInt(json['edad']),
      posicion: json['posicion'] ?? '',
      dorsal: _parseInt(json['dorsal']),
      altura: _parseDouble(json['altura']),
      peso: _parseDouble(json['peso']),

      puntosTotales: _parseInt(json['puntosTotales']),
      rebotesTotales: _parseInt(json['rebotesTotales']),
      asistenciasTotales: _parseInt(json['asistenciasTotales']),
      robosTotales: _parseInt(json['robosTotales']),
      partidosJugados: _parseInt(json['partidosJugados']),

      codigoJugador: json['codigoJugador'],
      verificado: json['verificado'] ?? false,
      tieneEquipo: json['tieneEquipo'] ?? false,
      equipoId: _parseIntNullable(json['equipoId']),
      nombreEquipo: json['nombreEquipo'],
    );
  }

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

