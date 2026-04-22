// lib/models/DTOS/Registro/registroJugadorDTO.dart
import '../../role.dart';
import 'registroBaseDTO.dart';

class RegistroJugadorDTO extends RegistroBaseDTO {
  final String codigoJugador;
  final String posicion;

  RegistroJugadorDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required super.apellido,
    required super.edad,
    required super.password,
    required this.codigoJugador,
    required this.posicion,
  }) {
    super.rol = Role.JUGADOR;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['codigoJugador'] = codigoJugador;
    json['posicion'] = posicion;
    json['rol'] = 'JUGADOR';
    return json;
  }
}