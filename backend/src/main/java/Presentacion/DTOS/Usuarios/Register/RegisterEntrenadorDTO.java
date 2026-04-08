package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class RegisterEntrenadorDTO extends RegistroBaseDTO {
    private String apellido;
    private String codigoEntrenador;

    public RegisterEntrenadorDTO() {
        setRol(Roles.ENTRENADOR);
    }
}