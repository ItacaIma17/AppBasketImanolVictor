package Presentacion.DTOS.Equipo;

import lombok.Data;

@Data
public class EquipoRequest {
    private String nombre;
    private String nombreEstadio;
    private Long ligaId;
}