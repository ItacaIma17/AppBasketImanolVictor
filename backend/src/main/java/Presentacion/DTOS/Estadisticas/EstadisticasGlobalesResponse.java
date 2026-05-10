package Presentacion.DTOS.Estadisticas;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class EstadisticasGlobalesResponse {
    private int totalJugadores;
    private int totalEquipos;
    private int totalLigas;
    private int totalPartidos;
    private int partidosFinalizados;
    private int partidosPendientes;
    private int partidosEnCurso;
    private int totalPuntosGlobal;
    private double promedioPuntosPorPartido;
}
