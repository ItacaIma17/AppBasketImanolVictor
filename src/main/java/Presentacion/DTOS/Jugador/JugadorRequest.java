package Presentacion.DTOS.Jugador;

import lombok.Data;

@Data
public class JugadorRequest {
    private String posicion;
    private int dorsal;
    private double altura;
    private double peso;
    private Long equipoId;
}