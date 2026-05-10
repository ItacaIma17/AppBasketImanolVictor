package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import lombok.Data;

@Data
public class RegistroBaseDTO {
    private String email;
    private String username;
    private String password;
    private String nombre;
    private int edad;
    private Roles rol;
}
