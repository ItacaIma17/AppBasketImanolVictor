// lib/models/dtos/actualizar_usuario_dto.dart
class ActualizarUsuarioDTO {
  final String? username;
  final String? oldPassword;
  final String? newPassword;

  ActualizarUsuarioDTO({
    this.username,
    this.oldPassword,
    this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}