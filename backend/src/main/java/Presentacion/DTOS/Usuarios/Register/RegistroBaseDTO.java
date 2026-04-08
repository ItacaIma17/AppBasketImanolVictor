package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import lombok.Data;

@JsonTypeInfo(
        use = JsonTypeInfo.Id.NAME,
        include = JsonTypeInfo.As.PROPERTY,
        property = "rol"
)
@JsonSubTypes({
        @JsonSubTypes.Type(value = RegisterEntrenadorDTO.class, name = "ENTRENADOR"),
        @JsonSubTypes.Type(value = RegistroArbitroDTO.class, name = "ARBITRO"),
        @JsonSubTypes.Type(value = RegistroJugadorDTO.class, name = "JUGADOR"),
        @JsonSubTypes.Type(value = RegistroUsuarioDTO.class, name = "USUARIO")
})
@Data
public abstract class RegistroBaseDTO {
    private String email;
    private String username;
    private String nombre;
    private int edad;
    private String password;
    private Roles rol;
}