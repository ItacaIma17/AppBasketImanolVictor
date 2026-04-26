package Presentacion.DTOS.Partido;

import Dominio.Entity.Partido;
import Dominio.Entity.JugadorAlineacion;
import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
public class PartidoResponseDTO {
    private Long id;
    private Long equipoLocalId;
    private String equipoLocal;
    private Long equipoVisitanteId;
    private String equipoVisitante;
    private Long arbitroId;
    private String arbitroNombre;
    private LocalDateTime fecha;
    private String ubicacion;
    private Integer resultadoLocal;
    private Integer resultadoVisitante;
    private String estado;
    private Boolean tieneActa;
    private Long actaId;
    private Boolean tieneAlineacionLocal;
    private Boolean tieneAlineacionVisitante;
    private Long alineacionLocalId;
    private Long alineacionVisitanteId;
    private List<JugadorAlineacionDTO> alineacionLocal;
    private List<JugadorAlineacionDTO> alineacionVisitante;

    @Data
    @Builder
    public static class JugadorAlineacionDTO {
        private Long id;
        private Long jugadorId;
        private String nombre;
        private String apellido;
        private String nombreCompleto;
        private int dorsal;
        private String posicion;
        private boolean titular;
    }

    public static PartidoResponseDTO fromEntity(Partido partido) {
        PartidoResponseDTOBuilder builder = PartidoResponseDTO.builder()
                .id(partido.getId())
                .equipoLocalId(partido.getEquipoLocal().getId())
                .equipoLocal(partido.getEquipoLocal().getNombre())
                .equipoVisitanteId(partido.getEquipoVisitante().getId())
                .equipoVisitante(partido.getEquipoVisitante().getNombre())
                .fecha(partido.getFecha())
                .ubicacion(partido.getUbicacion())
                .resultadoLocal(partido.getResultadoLocal())
                .resultadoVisitante(partido.getResultadoVisitante())
                .estado(partido.getEstado() != null ? partido.getEstado() : "PROGRAMADO")
                .tieneAlineacionLocal(partido.getAlineacionLocal() != null)
                .tieneAlineacionVisitante(partido.getAlineacionVisitante() != null);

        // ✅ CORREGIDO: Convertir Alineacion a List de JugadorAlineacionDTO
        if (partido.getAlineacionLocal() != null) {
            builder.alineacionLocalId(partido.getAlineacionLocal().getId())
                    .alineacionLocal(convertJugadoresToDTO(partido.getAlineacionLocal().getJugadores()));
        }

        if (partido.getAlineacionVisitante() != null) {
            builder.alineacionVisitanteId(partido.getAlineacionVisitante().getId())
                    .alineacionVisitante(convertJugadoresToDTO(partido.getAlineacionVisitante().getJugadores()));
        }

        if (partido.getArbitro() != null) {
            builder.arbitroId(partido.getArbitro().getId())
                    .arbitroNombre(partido.getArbitro().getNombre());
        }

        if (partido.getActa() != null) {
            builder.tieneActa(true)
                    .actaId(partido.getActa().getId());
        } else {
            builder.tieneActa(false);
        }

        return builder.build();
    }

    private static List<JugadorAlineacionDTO> convertJugadoresToDTO(List<JugadorAlineacion> jugadores) {
        if (jugadores == null || jugadores.isEmpty()) {
            return List.of();
        }

        return jugadores.stream()
                .map(jugador -> JugadorAlineacionDTO.builder()
                        .id(jugador.getId())
                        .jugadorId(jugador.getJugador().getId())
                        .nombre(jugador.getNombreJugador())
                        .apellido(jugador.getApellidoJugador())
                        .nombreCompleto((jugador.getNombreJugador() != null ? jugador.getNombreJugador() : "") + " " +
                                (jugador.getApellidoJugador() != null ? jugador.getApellidoJugador() : ""))
                        .dorsal(jugador.getDorsal())
                        .posicion(jugador.getPosicion())
                        .titular(jugador.isTitular())
                        .build())
                .collect(Collectors.toList());
    }
}