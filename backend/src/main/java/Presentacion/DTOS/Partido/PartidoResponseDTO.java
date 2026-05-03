package Presentacion.DTOS.Partido;

import Dominio.Entity.Partido;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class PartidoResponseDTO {
    private Long id;
    private Long equipoLocalId;
    private String equipoLocal;
    private Long equipoVisitanteId;
    private String equipoVisitante;
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

    public static PartidoResponseDTO fromEntity(Partido partido) {
        PartidoResponseDTO dto = new PartidoResponseDTO();
        dto.setId(partido.getId());
        dto.setEquipoLocalId(partido.getEquipoLocal().getId());
        dto.setEquipoLocal(partido.getEquipoLocal().getNombre());
        dto.setEquipoVisitanteId(partido.getEquipoVisitante().getId());
        dto.setEquipoVisitante(partido.getEquipoVisitante().getNombre());
        dto.setFecha(partido.getFecha());
        dto.setUbicacion(partido.getUbicacion());
        dto.setPabellon(partido.getPabellon());
        dto.setResultadoLocal(partido.getResultadoLocal());
        dto.setResultadoVisitante(partido.getResultadoVisitante());
        dto.setEstado(partido.getEstado());
        dto.setLigaId(partido.getLiga() != null ? partido.getLiga().getId() : null);
        dto.setLigaNombre(partido.getLiga() != null ? partido.getLiga().getNombreLiga() : null);
        dto.setArbitroId(partido.getArbitro() != null ? partido.getArbitro().getId() : null);
        dto.setArbitroNombre(partido.getArbitro() != null ? partido.getArbitro().getNombre() : null);
        return dto;
    }
}