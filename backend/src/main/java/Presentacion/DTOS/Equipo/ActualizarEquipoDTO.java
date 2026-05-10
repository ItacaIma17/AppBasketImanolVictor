package Presentacion.DTOS.Equipo;

import lombok.Data;

@Data
public class ActualizarEquipoDTO {
    private String nombre;
    private String nombreEstadio;
    private String ciudad;
    private int añoFundacion;
    private String escudoUrl;
    private Long ligaId;
}
