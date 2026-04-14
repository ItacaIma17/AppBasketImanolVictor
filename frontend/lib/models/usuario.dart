// lib/models/usuario.dart
import 'role.dart';

class Usuario {
  final int? id;
  final String email;
  final String username;
  final String nombre;
  final String apellido;
  final String? licencia;  // ← AÑADIDO (nullable porque solo jugadores/entrenadores/arbitros tienen)
  final int edad;
  final Role role;
  final bool verificado;
  final bool bloqueado;
  final String? codigoVerificacion;
  final DateTime? expiracionCodigo;
  final String? token;
  final String? refreshToken;
  final List<EquipoSiguiendo>? equiposSiguiendo;
  final List<JugadorSiguiendo>? jugadoresSiguiendo;

  Usuario({
    this.id,
    required this.email,
    required this.username,
    required this.nombre,
    required this.apellido,
    this.licencia,  // ← AÑADIDO
    required this.edad,
    required this.role,
    required this.verificado,
    required this.bloqueado,
    this.codigoVerificacion,
    this.expiracionCodigo,
    this.token,
    this.refreshToken,
    this.equiposSiguiendo,
    this.jugadoresSiguiendo,
  });

  /// Constructor desde JSON (respuesta del backend)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      licencia: json['licencia'],  // ← AÑADIDO
      edad: json['edad'] ?? 0,
      role: json['role'] != null
          ? Role.fromString(json['role'])
          : Role.USUARIO,
      verificado: json['verificado'] ?? false,
      bloqueado: json['bloqueado'] ?? false,
      codigoVerificacion: json['codigoVerificacion'],
      expiracionCodigo: json['expiracionCodigo'] != null
          ? DateTime.tryParse(json['expiracionCodigo'])
          : null,
      token: json['token'],
      refreshToken: json['refreshToken'],
      equiposSiguiendo: json['listaEquiposSiguiendo'] != null
          ? (json['listaEquiposSiguiendo'] as List)
          .map((e) => EquipoSiguiendo.fromJson(e))
          .toList()
          : null,
      jugadoresSiguiendo: json['listaJugadorSiguiendo'] != null
          ? (json['listaJugadorSiguiendo'] as List)
          .map((e) => JugadorSiguiendo.fromJson(e))
          .toList()
          : null,
    );
  }

  /// Convertir a JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'licencia': licencia,  // ← AÑADIDO
      'edad': edad,
      'role': role.value,
      'verificado': verificado,
      'bloqueado': bloqueado,
      'codigoVerificacion': codigoVerificacion,
      'expiracionCodigo': expiracionCodigo?.toIso8601String(),
      'token': token,
      'refreshToken': refreshToken,
      'listaEquiposSiguiendo': equiposSiguiendo?.map((e) => e.toJson()).toList(),
      'listaJugadorSiguiendo': jugadoresSiguiendo?.map((e) => e.toJson()).toList(),
    };
  }

  /// Obtener nombre completo
  String get nombreCompleto {
    if (apellido != null && apellido!.isNotEmpty) {
      return '$nombre $apellido';
    }
    return nombre;
  }

  /// Obtener iniciales para el avatar
  String get iniciales {
    if (apellido != null && apellido!.isNotEmpty && nombre.isNotEmpty) {
      return '${nombre[0]}${apellido![0]}'.toUpperCase();
    }
    if (nombre.isNotEmpty) {
      return nombre[0].toUpperCase();
    }
    return '?';
  }

  /// Verificar si el usuario tiene licencia (solo para jugadores, entrenadores y árbitros)
  bool get tieneLicencia {
    return licencia != null && licencia!.isNotEmpty;
  }

  /// Verificar si el usuario es admin
  bool get isAdmin => role == Role.ADMIN;

  /// Verificar si el usuario es entrenador
  bool get isEntrenador => role == Role.ENTRENADOR;

  /// Verificar si el usuario es árbitro
  bool get isArbitro => role == Role.ARBITRO;

  /// Verificar si el usuario es jugador
  bool get isJugador => role == Role.JUGADOR;

  /// Verificar si el usuario es aficionado
  bool get isAficionado => role == Role.USUARIO;

  /// Verificar si el usuario está autenticado (tiene token)
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  /// Verificar si la cuenta está completa (verificada y no bloqueada)
  bool get isActive => verificado && !bloqueado;

  /// Obtener el tipo de licencia según el rol
  String get tipoLicencia {
    if (licencia == null || licencia!.isEmpty) return 'Sin licencia';

    switch (role) {
      case Role.JUGADOR:
        return 'Licencia de Jugador';
      case Role.ENTRENADOR:
        return 'Licencia de Entrenador';
      case Role.ARBITRO:
        return 'Licencia Arbitral';
      default:
        return 'Licencia';
    }
  }

  /// Copiar usuario con campos modificados
  Usuario copyWith({
    int? id,
    String? email,
    String? username,
    String? nombre,
    String? apellido,
    String? licencia,  // ← AÑADIDO
    int? edad,
    Role? role,
    bool? verificado,
    bool? bloqueado,
    String? codigoVerificacion,
    DateTime? expiracionCodigo,
    String? token,
    String? refreshToken,
    List<EquipoSiguiendo>? equiposSiguiendo,
    List<JugadorSiguiendo>? jugadoresSiguiendo,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      licencia: licencia ?? this.licencia,  // ← AÑADIDO
      edad: edad ?? this.edad,
      role: role ?? this.role,
      verificado: verificado ?? this.verificado,
      bloqueado: bloqueado ?? this.bloqueado,
      codigoVerificacion: codigoVerificacion ?? this.codigoVerificacion,
      expiracionCodigo: expiracionCodigo ?? this.expiracionCodigo,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      equiposSiguiendo: equiposSiguiendo ?? this.equiposSiguiendo,
      jugadoresSiguiendo: jugadoresSiguiendo ?? this.jugadoresSiguiendo,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, username: $username, nombre: $nombre, role: ${role.value}, verificado: $verificado, licencia: ${licencia ?? "sin licencia"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modelo para equipos que sigue el usuario
class EquipoSiguiendo {
  final int id;
  final String nombre;
  final String? nombreLiga;

  EquipoSiguiendo({
    required this.id,
    required this.nombre,
    this.nombreLiga,
  });

  factory EquipoSiguiendo.fromJson(Map<String, dynamic> json) {
    return EquipoSiguiendo(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      nombreLiga: json['nombreLiga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombreLiga': nombreLiga,
    };
  }
}

/// Modelo para jugadores que sigue el usuario
class JugadorSiguiendo {
  final int id;
  final String nombre;
  final String? posicion;
  final String? nombreEquipo;

  JugadorSiguiendo({
    required this.id,
    required this.nombre,
    this.posicion,
    this.nombreEquipo,
  });

  factory JugadorSiguiendo.fromJson(Map<String, dynamic> json) {
    return JugadorSiguiendo(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      posicion: json['posicion'],
      nombreEquipo: json['nombreEquipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'posicion': posicion,
      'nombreEquipo': nombreEquipo,
    };
  }
}