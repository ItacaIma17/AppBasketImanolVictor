import '../../role.dart';
import 'registroBaseDTO.dart';

class RegistroArbitroDTO extends RegistroBaseDTO {
  final String codigoArbitro;

  RegistroArbitroDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required super.apellido,
    required super.edad,
    required super.password,
    required this.codigoArbitro,
  }) {
    super.rol = Role.ARBITRO;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['codigoArbitro'] = codigoArbitro;
    json['rol'] = 'ARBITRO';
    return json;
  }
}
