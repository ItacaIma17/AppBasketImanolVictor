// Presentacion/DTOS/Usuarios/Register/RegistroAdminDTO.java
package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class RegistroAdminDTO extends RegistroBaseDTO {
    private String apellido;
    private String adminKey;

    public RegistroAdminDTO() {
        setRol(Roles.ADMIN);
    }
}