package Presentacion.DTOS.Usuarios.Login;

import Dominio.Entity.Roles.Roles;
import Dominio.Entity.Usuario;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class LoginResponse {
    private String token;
    private String refreshToken;
    private String username;
    private String nombre;
    private String email;
    private String apellido;
    private String rol;
    private boolean verificado;

    public static LoginResponse fromEntity(Usuario usuario){
        if(usuario == null){
            return null;
        }

        return LoginResponse.builder()
                .token(usuario.getToken())
                .refreshToken(usuario.getRefreshToken())
                .username(usuario.getUsername())
                .apellido(usuario.getApellido())
                .nombre(usuario.getNombre())
                .rol(usuario.getRole().name())
                .verificado(usuario.isVerificado())
                .build();
    }
}

