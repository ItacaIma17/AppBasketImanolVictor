package Presentacion.DTOS.Arbitro;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ArbitroEstadisticasResponse {
    private Long id;
    private String nombre;
    private Integer totalPartidosAsignados;
    private Integer partidosFinalizados;
    private Integer partidosPendientes;
    private Boolean verificado;
}