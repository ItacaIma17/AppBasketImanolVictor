package Presentacion.DTOS.Usuarios.Login;

import lombok.Data;
@Data
public class LoginRequest {
    private String username;
    private String password;
}

