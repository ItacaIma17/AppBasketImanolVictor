package Presentacion.DTOS.Partido;

import Dominio.Entity.Partido;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class PartidoResponse {
    private Long id;
    private Long equipoLocalId;
    private String equipoLocal;
    private Long equipoVisitanteId;
    private String equipoVisitante;
    private LocalDateTime fecha;
    private String hora;        // ← añadido
    private String ubicacion;
    private String pabellon;
    private Integer resultadoLocal;
    private Integer resultadoVisitante;
    private String estado;
    private Long ligaId;
    private String ligaNombre;
    private Long arbitroId;
    private String arbitroNombre;
    private Integer jornada;    // ← añadido

    public static PartidoResponse fromEntity(Partido partido) {  // ← corregido tipo
        PartidoResponse dto = new PartidoResponse();             // ← corregido tipo
        dto.setId(partido.getId());
        dto.setEquipoLocalId((long) partido.getEquipoLocal().getId());
        dto.setEquipoLocal(partido.getEquipoLocal().getNombre());
        dto.setEquipoVisitanteId((long) partido.getEquipoVisitante().getId());
        dto.setEquipoVisitante(partido.getEquipoVisitante().getNombre());
        dto.setFecha(partido.getFecha());
        dto.setHora(partido.getHora());             // ← añadido
        dto.setUbicacion(partido.getUbicacion());
        dto.setPabellon(partido.getPabellon());
        dto.setResultadoLocal(partido.getResultadoLocal());
        dto.setResultadoVisitante(partido.getResultadoVisitante());
        dto.setEstado(partido.getEstado());
        dto.setLigaId(partido.getLiga() != null ? partido.getLiga().getId() : null);
        dto.setLigaNombre(partido.getLiga() != null ? partido.getLiga().getNombreLiga() : null);
        dto.setArbitroId(partido.getArbitro() != null ? partido.getArbitro().getId() : null);
        dto.setArbitroNombre(partido.getArbitro() != null ? partido.getArbitro().getNombre() : null);
        dto.setJornada(partido.getJornada());       // ← añadido
        return dto;
    }
}