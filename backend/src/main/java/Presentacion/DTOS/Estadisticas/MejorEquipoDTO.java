package Presentacion.DTOS.Estadisticas;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class MejorEquipoDTO {
    private Long equipoId;
    private String nombre;
    private String ciudad;
    private String liga;
    private int victorias;
    private int derrotas;
    private int porcentajeVictorias;
    private int puntosFavor;
    private int puntosContra;
    private int diferenciaPuntos;
}
