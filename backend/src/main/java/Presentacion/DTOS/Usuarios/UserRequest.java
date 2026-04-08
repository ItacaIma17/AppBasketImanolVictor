package Presentacion.DTOS.Usuarios;

import lombok.Data;

@Data
public class UserRequest {
    private String username;
    private String name;
    private String apellido;
    private String password;
    private String email;
}
