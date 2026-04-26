package Presentacion.DTOS.Partido;

import Dominio.Entity.Alineacion;
import Dominio.Entity.JugadorAlineacion;
import lombok.Builder;
import lombok.Data;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
public class AlineacionParaActaDTO {

    private Long partidoId;
    private String equipoLocal;
    private String equipoVisitante;

    private List<JugadorActaDTO> alineacionLocal;
    private List<JugadorActaDTO> alineacionVisitante;
    private List<JugadorActaDTO> suplentesLocal;
    private List<JugadorActaDTO> suplentesVisitante;

    @Data
    @Builder
    public static class JugadorActaDTO {
        private Long id;
        private Long jugadorId;
        private String nombre;
        private String apellido;
        private String nombreCompleto;
        private int dorsal;
        private String posicion;
        private boolean titular;
    }

    public static AlineacionParaActaDTO fromEntities(
            Alineacion alineacionLocal, Alineacion alineacionVisitante) {

        if (alineacionLocal == null || alineacionVisitante == null) {
            return null;
        }

        return AlineacionParaActaDTO.builder()
                .partidoId(alineacionLocal.getPartido().getId())
                .equipoLocal(alineacionLocal.getEquipo().getNombre())
                .equipoVisitante(alineacionVisitante.getEquipo().getNombre())
                .alineacionLocal(convertJugadoresToDTO(alineacionLocal.getTitulares()))
                .alineacionVisitante(convertJugadoresToDTO(alineacionVisitante.getTitulares()))
                .suplentesLocal(convertJugadoresToDTO(alineacionLocal.getSuplentes()))
                .suplentesVisitante(convertJugadoresToDTO(alineacionVisitante.getSuplentes()))
                .build();
    }

    private static List<JugadorActaDTO> convertJugadoresToDTO(List<JugadorAlineacion> jugadores) {
        if (jugadores == null || jugadores.isEmpty()) {
            return List.of();
        }

        return jugadores.stream()
                .map(jugador -> JugadorActaDTO.builder()
                        .id(jugador.getId())
                        .jugadorId(jugador.getJugador() != null ? jugador.getJugador().getId() : null)
                        .nombre(jugador.getNombreJugador())
                        .apellido(jugador.getApellidoJugador())
                        .nombreCompleto((jugador.getNombreJugador() != null ? jugador.getNombreJugador() : "") +
                                " " + (jugador.getApellidoJugador() != null ? jugador.getApellidoJugador() : ""))
                        .dorsal(jugador.getDorsal())
                        .posicion(jugador.getPosicion())
                        .titular(jugador.isTitular())
                        .build())
                .collect(Collectors.toList());
    }
}