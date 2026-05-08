package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class RegistroJugadorDTO extends RegistroBaseDTO {
    private String apellido;
    private double altura;
    private double peso;
    private String posicion;
    private int dorsal;
    private String codigoJugador;
    private Long equipoId;

    public RegistroJugadorDTO() {
        setRol(Roles.JUGADOR);
    }
}