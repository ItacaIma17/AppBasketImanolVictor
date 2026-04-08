package Presentacion.DTOS.Jugador;

import lombok.Data;

@Data
public class JugadorResponse {
    private Long id;
    private String nombre;
    private String apellido;
    private String username;
    private String email;
    private int edad;
    private double altura;
    private double peso;
    private String posicion;
    private int dorsal;
    private String role;
    private Long equipoId;
    private String equipoNombre;
    private String ligaNombre;
}