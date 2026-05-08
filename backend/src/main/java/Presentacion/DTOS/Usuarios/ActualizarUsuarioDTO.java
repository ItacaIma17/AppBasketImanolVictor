package Presentacion.DTOS.Usuarios;

import lombok.Data;

@Data
public class ActualizarUsuarioDTO {

    private String username;

    private String oldPassword;

    private String newPassword;
}
