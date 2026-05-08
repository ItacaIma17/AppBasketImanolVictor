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

    // En PartidoResponseDTO.java

    public static PartidoResponse fromEntity(Partido partido) {
        PartidoResponse dto = new PartidoResponse();
        dto.setId(partido.getId());

        // Asegurar que los nombres se incluyen
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

        // ✅ Resultados (necesarios para mostrar marcador en el frontend)
        dto.setResultadoLocal(partido.getResultadoLocal());
        dto.setResultadoVisitante(partido.getResultadoVisitante());

        // ✅ Liga (id + nombre). En la entidad Liga el campo se llama
        // `nombreLiga` (no `nombre`).
        if (partido.getLiga() != null) {
            dto.setLigaId(partido.getLiga().getId());
            dto.setLigaNombre(partido.getLiga().getNombreLiga());
        }

        // ✅ Árbitro (id + nombre completo) — necesario para que el front
        // sepa si el partido ya tiene árbitro asignado y muestre quién es.
        if (partido.getArbitro() != null) {
            dto.setArbitroId(partido.getArbitro().getId());
            String nombreCompleto = partido.getArbitro().getNombre();
            if (partido.getArbitro().getApellidos() != null) {
                nombreCompleto = (nombreCompleto + " " + partido.getArbitro().getApellidos()).trim();
            }
            dto.setArbitroNombre(nombreCompleto);
        }

        return dto;
    }
}