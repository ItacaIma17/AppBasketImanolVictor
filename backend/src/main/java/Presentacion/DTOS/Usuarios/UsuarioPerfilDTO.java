package Presentacion.DTOS.Usuarios;

import Dominio.Entity.Roles.Roles;
import Dominio.Entity.Usuario;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioPerfilDTO {
    private Long id;
    private String email;
    private String username;
    private String nombre;
    private String apellido;
    private int edad;
    private Roles rol;
    private boolean verificado;
    private boolean bloqueado;

    public static UsuarioPerfilDTO fromEntity(Usuario usuario) {
        if (usuario == null) {
            return null;
        }

        return UsuarioPerfilDTO.builder()
                .id(usuario.getId())
                .email(usuario.getEmail())
                .username(usuario.getUsername())
                .nombre(usuario.getNombre())
                .apellido(usuario.getApellido())
                .edad(usuario.getEdad())
                .rol(usuario.getRole())
                .verificado(usuario.isVerificado())
                .bloqueado(usuario.isBloqueado())
                .build();
    }
}
