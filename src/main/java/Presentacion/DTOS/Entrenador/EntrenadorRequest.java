package Presentacion.DTOS.Entrenador;

import lombok.Data;

@Data
public class EntrenadorRequest {
    private String nombre;
    private String apellido;
    private int edad;
}