package Presentacion.DTOS.Partido;

import Dominio.Entity.Partido;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class PartidoResponse {
    private Long id;
    private Long equipoLocalId;
    private String nombreLocal;
    private Long equipoVisitanteId;
    private String nombreVisitante;
    private LocalDateTime fecha;
    private String ubicacion;
    private String pabellon;
    private Integer resultadoLocal;
    private Integer resultadoVisitante;
    private String estado;
    private Long ligaId;
    private String ligaNombre;
    private Long arbitroId;
    private String arbitroNombre;
    private Integer jornada;
    private Boolean tieneAlineacionLocal;
    private Boolean tieneAlineacionVisitante;
    private Boolean alineacionLocalConfirmada;
    private Boolean alineacionVisitanteConfirmada;
    private Long alineacionLocalId;
    private Long alineacionVisitanteId;
    private Boolean tieneActa;
    private Long actaId;

    public static PartidoResponse fromEntity(Partido partido) {
        PartidoResponse dto = new PartidoResponse();
        dto.setId(partido.getId());

        if (partido.getEquipoLocal() != null) {
            dto.setEquipoLocalId(partido.getEquipoLocal().getId());
            dto.setNombreLocal(partido.getEquipoLocal().getNombre());
        }

        if (partido.getEquipoVisitante() != null) {
            dto.setEquipoVisitanteId(partido.getEquipoVisitante().getId());
            dto.setNombreVisitante(partido.getEquipoVisitante().getNombre());
        }

        dto.setFecha(partido.getFecha());
        dto.setEstado(partido.getEstado());
        dto.setUbicacion(partido.getUbicacion());
        dto.setPabellon(partido.getPabellon());
        dto.setJornada(partido.getJornada());

        dto.setResultadoLocal(partido.getResultadoLocal());
        dto.setResultadoVisitante(partido.getResultadoVisitante());

        if (partido.getLiga() != null) {
            dto.setLigaId(partido.getLiga().getId());
            dto.setLigaNombre(partido.getLiga().getNombreLiga());
        }

        if (partido.getArbitro() != null) {
            dto.setArbitroId(partido.getArbitro().getId());
            String nombreCompleto = partido.getArbitro().getNombre();
            if (partido.getArbitro().getApellidos() != null) {
                nombreCompleto = (nombreCompleto + " " + partido.getArbitro().getApellidos()).trim();
            }
            dto.setArbitroNombre(nombreCompleto);
        }

        dto.setTieneActa(partido.getActaPartido() != null);
        if (partido.getActaPartido() != null) {
            dto.setActaId(partido.getActaPartido().getId());
        }

        return dto;
    }
}
