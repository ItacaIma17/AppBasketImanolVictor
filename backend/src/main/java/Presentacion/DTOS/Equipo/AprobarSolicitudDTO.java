package Presentacion.DTOS.Equipo;

import lombok.Data;

@Data
public class AprobarSolicitudDTO {
    private String codigoSolicitud;
    private Long entrenadorId;
    private Boolean aprobar;
}
