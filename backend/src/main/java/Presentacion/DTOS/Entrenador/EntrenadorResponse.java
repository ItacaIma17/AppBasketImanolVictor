package Presentacion.DTOS.Entrenador;

import lombok.Data;

@Data
public class EntrenadorResponse {
    private Long id;
    private String nombre;
    private String apellido;
    private String username;
    private String email;
    private int edad;
    private String role;
    private String equipoNombre;
    private Long equipoId;
}
