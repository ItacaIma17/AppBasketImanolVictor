package Presentacion.DTOS.Partido;

import lombok.Data;

@Data
public class PartidoRequest {

    private Long equipoLocalId;
    private Long equipoVisitanteId;

    private String fecha;
    private String hora;

    private String pabellon;
    private String direccionPabellon;

    private Long ligaId;
    private Long arbitroId;

    private String estado;
    private String actaUrl;
    private String observaciones;
}
