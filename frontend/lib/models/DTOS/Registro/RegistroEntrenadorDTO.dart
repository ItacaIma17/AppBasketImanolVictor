import '../../role.dart';
import 'registroBaseDTO.dart';

class RegisterEntrenadorDTO extends RegistroBaseDTO {
  final String codigoEntrenador;

  RegisterEntrenadorDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required super.apellido,
    required super.edad,
    required super.password,
    required this.codigoEntrenador,
  }) {
    super.rol = Role.ENTRENADOR;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['codigoEntrenador'] = codigoEntrenador;
    json['rol'] = 'ENTRENADOR';
    return json;
  }
}
