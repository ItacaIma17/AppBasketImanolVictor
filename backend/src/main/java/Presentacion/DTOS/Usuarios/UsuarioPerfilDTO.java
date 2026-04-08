package Presentacion.DTOS.Usuarios;

import Dominio.Entity.Usuario;
import lombok.Data;

@Data
public class UsuarioPerfilDTO {
    private String email;
    private String username;
    private String nombre;
    private String apellido;
    private int edad;
    private String rol;
    private boolean verificado;

    public static UsuarioPerfilDTO fromEntity(Usuario usuario) {
        UsuarioPerfilDTO dto = new UsuarioPerfilDTO();
        dto.setEmail(usuario.getEmail());
        dto.setUsername(usuario.getUsername());
        dto.setNombre(usuario.getNombre());
        dto.setApellido(usuario.getApellido());
        dto.setEdad(usuario.getEdad());
        dto.setRol(usuario.getRole().name());
        dto.setVerificado(usuario.isVerificado());
        return dto;
    }
}