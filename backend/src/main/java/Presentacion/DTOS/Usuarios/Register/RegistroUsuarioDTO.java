package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class RegistroUsuarioDTO extends RegistroBaseDTO {
    private String apellido;

    public RegistroUsuarioDTO() {
        setRol(Roles.USUARIO);
    }
}