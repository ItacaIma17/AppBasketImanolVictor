package Presentacion.DTOS.Entrenador;

import Dominio.Entity.Alineacion;
import Dominio.Entity.JugadorAlineacion;
import Presentacion.DTOS.Jugador.JugadorAlineacionRequestDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
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

    private boolean bloqueada;

    private List<JugadorAlineacionRequestDTO> titulares;

    private List<JugadorAlineacionRequestDTO> suplentes;

    // ============================================================
    // MÉTODO fromEntity (UN SOLO DTO)
    // ============================================================

    public static AlineacionResponseDTO fromEntity(Alineacion alineacion) {
        if (alineacion == null) return null;

        return AlineacionResponseDTO.builder()
                .id(alineacion.getId())
                .partidoId(alineacion.getPartido().getId())
                .equipoLocal(alineacion.getPartido().getEquipoLocal().getNombre())
                .equipoVisitante(alineacion.getPartido().getEquipoVisitante().getNombre())
                .equipoId(alineacion.getEquipo().getId())
                .nombreEquipo(alineacion.getEquipo().getNombre())
                .entrenadorId(alineacion.getEntrenador() != null ? alineacion.getEntrenador().getId() : null)
                .nombreEntrenador(alineacion.getEntrenador() != null ?
                        alineacion.getEntrenador().getNombre() + " " + alineacion.getEntrenador().getApellido() : null)
                .fechaPresentacion(alineacion.getFechaPresentacion())
                .confirmada(alineacion.isConfirmada())
                .bloqueada(alineacion.isBloqueada())
                .titulares(alineacion.getTitulares().stream()
                        .map(ja -> JugadorAlineacionRequestDTO.builder()
                                .jugadorId(ja.getJugador().getId())
                                .nombre(ja.getNombreJugador())
                                .apellido(ja.getApellidoJugador())
                                .dorsal(ja.getDorsal())
                                .posicion(ja.getPosicion())
                                .titular(true)
                                .build())
                        .collect(Collectors.toList()))
                .suplentes(alineacion.getSuplentes().stream()
                        .map(ja -> JugadorAlineacionRequestDTO.builder()
                                .jugadorId(ja.getJugador().getId())
                                .nombre(ja.getNombreJugador())
                                .apellido(ja.getApellidoJugador())
                                .dorsal(ja.getDorsal())
                                .posicion(ja.getPosicion())
                                .titular(false)
                                .build())
                        .collect(Collectors.toList()))
                .build();
    }

    // ============================================================
    // MÉTODO fromEntities (PARA LISTAS - CON "S")
    // ============================================================

    /**
     * Convierte una lista de entidades Alineacion a una lista de AlineacionResponseDTO
     *
     * @param alineaciones Lista de entidades Alineacion
     * @return Lista de AlineacionResponseDTO
     */
    public static List<AlineacionResponseDTO> fromEntities(List<Alineacion> alineaciones) {
        if (alineaciones == null) {
            return List.of();
        }
        return alineaciones.stream()
                .map(AlineacionResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // ============================================================
    // MÉTODO fromEntitiesConPartido (PARA OBTENER AMBAS ALINEACIONES)
    // ============================================================

    /**
     * Crea un DTO combinado con ambas alineaciones del partido
     *
     * @param alineacionLocal Alineación del equipo local
     * @param alineacionVisitante Alineación del equipo visitante
     * @param partidoId ID del partido
     * @param nombreLocal Nombre del equipo local
     * @param nombreVisitante Nombre del equipo visitante
     * @return Map con la información combinada
     */
    public static java.util.Map<String, Object> fromEntitiesConPartido(
            AlineacionResponseDTO alineacionLocal,
            AlineacionResponseDTO alineacionVisitante,
            Long partidoId,
            String nombreLocal,
            String nombreVisitante) {

        boolean localPresente = alineacionLocal != null;
        boolean visitantePresente = alineacionVisitante != null;
        boolean ambasPresentadas = localPresente && visitantePresente;
        boolean localConfirmada = localPresente && alineacionLocal.isConfirmada();
        boolean visitanteConfirmada = visitantePresente && alineacionVisitante.isConfirmada();

        java.util.Map<String, Object> response = new java.util.LinkedHashMap<>();
        response.put("partidoId", partidoId);
        response.put("equipoLocal", nombreLocal);
        response.put("equipoVisitante", nombreVisitante);
        response.put("alineacionLocal", alineacionLocal);
        response.put("alineacionVisitante", alineacionVisitante);
        response.put("ambasPresentadas", ambasPresentadas);
        response.put("alineacionLocalConfirmada", localConfirmada);
        response.put("alineacionVisitanteConfirmada", visitanteConfirmada);
        response.put("partidoListoParaComenzar", localConfirmada && visitanteConfirmada);

        return response;
    }
}