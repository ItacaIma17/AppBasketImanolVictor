package Presentacion.DTOS.Estadisticas;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TopScorerDTO {
    private Long jugadorId;
    private String nombre;
    private String posicion;
    private String equipo;
    private int puntosTotales;
    private int partidosJugados;
    private double promedio;
}
