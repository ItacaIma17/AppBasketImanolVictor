import '../../role.dart';
import '../Registro/registroBaseDTO.dart';

class RegistroAdminDTO extends RegistroBaseDTO {
  final String adminKey;

  RegistroAdminDTO({
    required super.email,
    required super.username,
    required super.nombre,
    required super.apellido,
    required super.edad,
    required super.password,
    required this.adminKey,
  }) {
    super.rol = Role.ADMIN;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['adminKey'] = adminKey;
    json['rol'] = 'ADMIN';
    return json;
  }
}
