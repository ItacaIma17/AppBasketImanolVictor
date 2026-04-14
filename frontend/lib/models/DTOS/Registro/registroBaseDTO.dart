
// DTO Base Abstracto
import '../../role.dart';

abstract class RegistroBaseDTO {
  String email;
  String username;
  String nombre;
  int edad;
  String password;
  Role rol;

  RegistroBaseDTO({
    required this.email,
    required this.username,
    required this.nombre,
    required this.edad,
    required this.password,
    required this.rol,
  });

  Map<String, dynamic> toJson();
}

// Registro para USUARIO / AFICIONADO
class RegistroUsuarioDTO extends RegistroBaseDTO {
  String apellido;

  RegistroUsuarioDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required this.apellido,
    required super.edad,
    required super.password,
  }) : super(rol: Role.USUARIO);

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'password': password,
      'rol': rol.value,
    };
  }
}

// Registro para ENTRENADOR
class RegisterEntrenadorDTO extends RegistroBaseDTO {
  String apellido;
  String codigoEntrenador;

  RegisterEntrenadorDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required this.apellido,
    required super.edad,
    required super.password,
    required this.codigoEntrenador,
  }) : super(rol: Role.ENTRENADOR);

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'password': password,
      'rol': rol.value,
      'codigoEntrenador': codigoEntrenador,
    };
  }
}

// Registro para ÁRBITRO
class RegistroArbitroDTO extends RegistroBaseDTO {
  String apellidos;
  String codigoArbitro;

  RegistroArbitroDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required this.apellidos,
    required super.edad,
    required super.password,
    required this.codigoArbitro,
  }) : super(rol: Role.ARBITRO);

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'nombre': nombre,
      'apellidos': apellidos,
      'edad': edad,
      'password': password,
      'rol': rol.value,
      'codigoArbitro': codigoArbitro,
    };
  }
}

// Registro para JUGADOR
class RegistroJugadorDTO extends RegistroBaseDTO {
  String apellido;
  String codigoJugador;
  String posicion;

  RegistroJugadorDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required this.apellido,
    required super.edad,
    required super.password,
    required this.codigoJugador,
    required this.posicion,
  }) : super(rol: Role.JUGADOR);

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'edad': edad,
      'password': password,
      'rol': rol.value,
      'codigoJugador': codigoJugador,
      'posicion': posicion,
    };
  }
}