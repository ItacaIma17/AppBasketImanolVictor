package Presentacion.DTOS.Arbitro;

import Dominio.Entity.ActaPartido;
import Dominio.Entity.EventoPartido;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
public class ActaResponseDTO {
    private Long id;
    private Long partidoId;
    private String equipoLocal;
    private String equipoVisitante;
    private String resultadoLocal;
    private String resultadoVisitante;
    private Long arbitroId;
    private String arbitroNombre;
    private LocalDateTime fechaActa;
    private String observaciones;
    private List<EventoResponseDTO> eventos;
    private Boolean puedeEditar;

    @Data
    @Builder
    public static class EventoResponseDTO {
        private Long id;
        private Long jugadorId;
        private String nombreJugador;
        private String nombreEquipo;
        private Integer minuto;
        private String tipo;
        private String descripcion;
        private Integer puntos;
    }

    public static ActaResponseDTO fromEntity(ActaPartido acta, String usuarioActual) {
        if (acta == null) return null;

        boolean puedeEditar = usuarioActual != null &&
                (usuarioActual.equals(acta.getArbitro().getUsername()) ||
                        usuarioActual.equals("admin"));

        return ActaResponseDTO.builder()
                .id(acta.getId())
                .partidoId(acta.getPartido().getId())
                .equipoLocal(acta.getPartido().getEquipoLocal().getNombre())
                .equipoVisitante(acta.getPartido().getEquipoVisitante().getNombre())
                .resultadoLocal(acta.getResultadoLocal())
                .resultadoVisitante(acta.getResultadoVisitante())
                .arbitroId(acta.getArbitro().getId())
                .arbitroNombre(acta.getArbitro().getNombre())
                .fechaActa(acta.getFechaActa())
                .observaciones(acta.getObservaciones())
                .eventos(acta.getEventos().stream()
                        .map(evento -> EventoResponseDTO.builder()
                                .id(evento.getId())
                                .jugadorId(evento.getJugador() != null ? evento.getJugador().getId() : null)
                                .nombreJugador(evento.getNombreJugador())
                                .nombreEquipo(evento.getNombreEquipo())
                                .minuto(evento.getMinuto())
                                .tipo(evento.getTipo())
                                .descripcion(evento.getDescripcion())
                                .puntos(evento.getPuntos())
                                .build())
                        .collect(Collectors.toList()))
                .puedeEditar(puedeEditar)
                .build();
    }
}
