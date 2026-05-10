package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class RegistroArbitroDTO extends RegistroBaseDTO {
    private String apellidos;
    private String codigoArbitro;

    public RegistroArbitroDTO() {
        setRol(Roles.ARBITRO);
    }
}
