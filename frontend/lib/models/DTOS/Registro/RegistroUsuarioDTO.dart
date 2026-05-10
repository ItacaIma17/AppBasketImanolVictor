import '../../role.dart';
import 'registroBaseDTO.dart';

class RegistroUsuarioDTO extends RegistroBaseDTO {
  RegistroUsuarioDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required super.apellido,
    required super.edad,
    required super.password,
  }) {
    super.rol = Role.USUARIO;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['rol'] = 'USUARIO';
    return json;
  }
}
