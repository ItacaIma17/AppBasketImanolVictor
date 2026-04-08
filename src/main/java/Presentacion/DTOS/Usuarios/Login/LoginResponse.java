package Presentacion.DTOS.Usuarios.Login;

import Dominio.Entity.Roles.Roles;
import lombok.Data;

@Data
public class LoginResponse {
    private String token;
    private String refreshToken;
    private String username;
    private String nombre;
    private String email;
    private String apellido;
    private String rol;
}
