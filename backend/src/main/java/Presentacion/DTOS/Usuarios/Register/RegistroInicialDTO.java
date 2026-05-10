package Presentacion.DTOS.Usuarios.Register;

import Dominio.Entity.Roles.Roles;
import lombok.Data;

@Data
public class RegistroInicialDTO {
    private String email;

    private String username;

    private String nombre;

    private int edad;

    private String apellido;

    private String password;

    private Roles rol;

}

