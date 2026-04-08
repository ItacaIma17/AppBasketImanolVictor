package Presentacion.DTOS.Usuarios;

import lombok.Data;

@Data
public class ActualizarUsuarioDTO {

    private String nombre;

    private String apellido;

    private String password;
}
