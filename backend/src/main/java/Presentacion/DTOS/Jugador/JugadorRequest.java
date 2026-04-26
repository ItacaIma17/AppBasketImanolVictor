package Presentacion.DTOS.Jugador;

import lombok.Data;

@Data
public class JugadorRequest {

    private String posicion;
    private int dorsal;
    private double altura;
    private double peso;
    private Long equipoId;
    private int puntosTotales;
    private int rebotesTotales;
    private int asistenciasTotales;
    private int robosTotales;
    private int partidosJugados;
}
