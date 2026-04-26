package Presentacion.DTOS.Partido;

import lombok.Data;

@Data
public class PartidoResponse {

    private Long id;
    private Long equipoLocalId;
    private Long equipoVisitanteId;

    private String nombreLocal;
    private String nombreVisitante;

    private Integer marcadorLocal;
    private Integer marcadorVisitante;

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
