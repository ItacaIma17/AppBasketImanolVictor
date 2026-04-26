package Presentacion.DTOS.Entrenador;

import Dominio.Entity.Alineacion;
import Dominio.Entity.JugadorAlineacion;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
public class AlineacionResponseDTO {

    private Long id;
    private Long partidoId;
    private String equipoLocal;
    private String equipoVisitante;
    private Long equipoId;
    private String nombreEquipo;
    private Long entrenadorId;
    private String nombreEntrenador;
    private LocalDateTime fechaPresentacion;
    private boolean confirmada;
    private List<JugadorAlineacionResponseDTO> titulares;
    private List<JugadorAlineacionResponseDTO> suplentes;

    @Data
    @Builder
    public static class JugadorAlineacionResponseDTO {
        private Long id;
        private Long jugadorId;
        private String nombre;
        private String apellido;
        private String nombreCompleto;
        private int dorsal;
        private String posicion;
        private boolean titular;
    }

    /**
     * Convierte una entidad Alineacion a AlineacionResponseDTO
     */
    public static AlineacionResponseDTO fromEntity(Alineacion alineacion) {
        if (alineacion == null) {
            return null;
        }

        return AlineacionResponseDTO.builder()
                .id(alineacion.getId())
                .partidoId(alineacion.getPartido() != null ? alineacion.getPartido().getId() : null)
                .equipoLocal(alineacion.getPartido() != null && alineacion.getPartido().getEquipoLocal() != null ?
                        alineacion.getPartido().getEquipoLocal().getNombre() : null)
                .equipoVisitante(alineacion.getPartido() != null && alineacion.getPartido().getEquipoVisitante() != null ?
                        alineacion.getPartido().getEquipoVisitante().getNombre() : null)
                .equipoId(alineacion.getEquipo() != null ? alineacion.getEquipo().getId() : null)
                .nombreEquipo(alineacion.getEquipo() != null ? alineacion.getEquipo().getNombre() : null)
                .entrenadorId(alineacion.getEntrenador() != null ? alineacion.getEntrenador().getId() : null)
                .nombreEntrenador(alineacion.getEntrenador() != null ?
                        alineacion.getEntrenador().getNombre() + " " +
                                (alineacion.getEntrenador().getApellido() != null ? alineacion.getEntrenador().getApellido() : "") : "Sin asignar")
                .fechaPresentacion(alineacion.getFechaPresentacion())
                .confirmada(alineacion.isConfirmada())
                .titulares(convertJugadoresToDTO(alineacion.getTitulares()))
                .suplentes(convertJugadoresToDTO(alineacion.getSuplentes()))
                .build();
    }

    /**
     * Convierte una lista de JugadorAlineacion a lista de JugadorAlineacionResponseDTO
     */
    private static List<JugadorAlineacionResponseDTO> convertJugadoresToDTO(List<JugadorAlineacion> jugadores) {
        if (jugadores == null || jugadores.isEmpty()) {
            return List.of();
        }

        return jugadores.stream()
                .map(jugador -> JugadorAlineacionResponseDTO.builder()
                        .id(jugador.getId())
                        .jugadorId(jugador.getJugador() != null ? jugador.getJugador().getId() : null)
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

    /**
     * Crea un DTO con listas separadas de titulares y suplentes
     */
    public static AlineacionResponseDTO fromLists(Long partidoId, String equipoLocal,
                                                  String equipoVisitante, Long equipoId, String nombreEquipo,
                                                  List<JugadorAlineacionResponseDTO> titulares,
                                                  List<JugadorAlineacionResponseDTO> suplentes) {

        return AlineacionResponseDTO.builder()
                .partidoId(partidoId)
                .equipoLocal(equipoLocal)
                .equipoVisitante(equipoVisitante)
                .equipoId(equipoId)
                .nombreEquipo(nombreEquipo)
                .fechaPresentacion(LocalDateTime.now())
                .confirmada(false)
                .titulares(titulares != null ? titulares : List.of())
                .suplentes(suplentes != null ? suplentes : List.of())
                .build();
    }

    /**
     * Crea un DTO con los datos básicos del partido
     */
    public static AlineacionResponseDTO basicInfo(Long partidoId, String equipoLocal, String equipoVisitante) {
        return AlineacionResponseDTO.builder()
                .partidoId(partidoId)
                .equipoLocal(equipoLocal)
                .equipoVisitante(equipoVisitante)
                .fechaPresentacion(LocalDateTime.now())
                .confirmada(false)
                .titulares(List.of())
                .suplentes(List.of())
                .build();
    }
}