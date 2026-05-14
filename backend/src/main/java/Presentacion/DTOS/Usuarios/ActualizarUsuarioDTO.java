package Presentacion.DTOS.Usuarios;

import lombok.Data;

@Data
public class ActualizarUsuarioDTO {

    private String username;

    private String nombre;

    private String apellido;

    private Integer edad;

    private String oldPassword;

    private String newPassword;
}

