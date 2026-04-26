// lib/models/jugador.dart
import 'package:tfg_appfede/models/role.dart';

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

  // Campos de estadísticas
  final double promedioPuntos;
  final double promedioRebotes;
  final double promedioAsistencias;
  final double promedioRobos;

  // Campos adicionales
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
    required this.promedioPuntos,
    required this.promedioRebotes,
    required this.promedioAsistencias,
    required this.promedioRobos,
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
      promedioPuntos: (json['promedioPuntos'] ?? 0.0).toDouble(),
      promedioRebotes: (json['promedioRebotes'] ?? 0.0).toDouble(),
      promedioAsistencias: (json['promedioAsistencias'] ?? 0.0).toDouble(),
      promedioRobos: (json['promedioRobos'] ?? 0.0).toDouble(),
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
      'promedioPuntos': promedioPuntos,
      'promedioRebotes': promedioRebotes,
      'promedioAsistencias': promedioAsistencias,
      'promedioRobos': promedioRobos,
      'codigoJugador': codigoJugador,
      'verificado': verificado,
      'tieneEquipo': tieneEquipo,
      'equipoId': equipoId,
      'nombreEquipo': nombreEquipo,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  Jugador copyWith({
    int? id,
    String? username,
    String? email,
    String? nombre,
    String? apellido,
    int? edad,
    String? posicion,
    int? dorsal,
    double? altura,
    double? peso,
    double? promedioPuntos,
    double? promedioRebotes,
    double? promedioAsistencias,
    double? promedioRobos,
    String? codigoJugador,
    bool? verificado,
    bool? tieneEquipo,
    int? equipoId,
    String? nombreEquipo,
  }) {
    return Jugador(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      edad: edad ?? this.edad,
      posicion: posicion ?? this.posicion,
      dorsal: dorsal ?? this.dorsal,
      altura: altura ?? this.altura,
      peso: peso ?? this.peso,
      promedioPuntos: promedioPuntos ?? this.promedioPuntos,
      promedioRebotes: promedioRebotes ?? this.promedioRebotes,
      promedioAsistencias: promedioAsistencias ?? this.promedioAsistencias,
      promedioRobos: promedioRobos ?? this.promedioRobos,
      codigoJugador: codigoJugador ?? this.codigoJugador,
      verificado: verificado ?? this.verificado,
      tieneEquipo: tieneEquipo ?? this.tieneEquipo,
      equipoId: equipoId ?? this.equipoId,
      nombreEquipo: nombreEquipo ?? this.nombreEquipo,
    );
  }

  // ============================================================
  // EQUALS y HASHCODE
  // ============================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Jugador && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Jugador{id: $id, nombre: $nombre, posicion: $posicion, dorsal: $dorsal, equipo: $nombreEquipo}';
  }
}