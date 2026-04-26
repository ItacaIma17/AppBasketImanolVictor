package Presentacion.DTOS.Equipo;

import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EquipoResponse {
    private Long id;
    private String nombre;
    private String ciudad;
    private String nombreEstadio;
    private Integer añoFundacion;
    private String escudoUrl;
    private String nombreLiga;
    private String nombreEntrenador;
    private Boolean tieneEntrenador;
    private String codigoSolicitud;
    private Boolean solicitudPendiente;

    public static EquipoResponse fromEntity(Equipo equipo) {
        return EquipoResponse.builder()
                .id(equipo.getId())
                .nombre(equipo.getNombre())
                .ciudad(equipo.getCiudad())
                .nombreEstadio(equipo.getNombreEstadio())
                .añoFundacion(equipo.getAnoFundacion())
                .escudoUrl(equipo.getEscudoUrl())
                .nombreLiga(equipo.getLiga() != null ? equipo.getLiga().getNombreLiga() : "Sin liga")
                .nombreEntrenador(equipo.getEntrenador() != null ?
                        equipo.getEntrenador().getNombre() + " " + equipo.getEntrenador().getApellido() : "Sin entrenador")
                .tieneEntrenador(equipo.getEntrenador() != null)
                .codigoSolicitud(equipo.getCodigoSolicitud())
                .solicitudPendiente(equipo.getSolicitudPendiente() != null && equipo.getSolicitudPendiente())
                .build();
    }
}