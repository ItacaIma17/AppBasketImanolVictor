package Presentacion.DTOS.Jugador;

import Dominio.Entity.Jugador;
import lombok.Data;

import java.util.List;
import java.util.stream.Collectors;

@Data
public class JugadorResponse {
    private Long id;
    private String nombre;
    private String apellido;
    private String username;
    private String email;
    private int edad;
    private double altura;
    private double peso;
    private String posicion;
    private int dorsal;
    private String role;
    private Long equipoId;
    private String equipoNombre;
    private String ligaNombre;
    private int puntosTotales;
    private int rebotesTotales;
    private int asistenciasTotales;
    private int robosTotales;
    private int partidosJugados;

    public static JugadorResponse fromEntity(Jugador jugador) {
        if (jugador == null) {
            return null;
        }

        JugadorResponse response = new JugadorResponse();
        response.setId(jugador.getId());
        response.setNombre(jugador.getNombre());
        response.setApellido(jugador.getApellido());
        response.setUsername(jugador.getUsername());
        response.setEmail(jugador.getEmail());
        response.setEdad(jugador.getEdad());
        response.setAltura(jugador.getAltura());
        response.setPeso(jugador.getPeso());
        response.setPosicion(jugador.getPosicion());
        response.setDorsal(jugador.getDorsal());
        response.setRole(jugador.getRole() != null ? jugador.getRole().name() : "JUGADOR");

        response.setPuntosTotales(jugador.getPuntosTotales());
        response.setRebotesTotales(jugador.getRebotesTotales());
        response.setAsistenciasTotales(jugador.getAsistenciasTotales());
        response.setRobosTotales(jugador.getRobosTotales());
        response.setPartidosJugados(jugador.getPartidosJugados());

        if (jugador.getEquipo() != null) {
            response.setEquipoId(jugador.getEquipo().getId());
            response.setEquipoNombre(jugador.getEquipo().getNombre());

            if (jugador.getEquipo().getLiga() != null) {
                response.setLigaNombre(jugador.getEquipo().getLiga().getNombreLiga());
            }
        }

        return response;
    }

    public static List<JugadorResponse> fromEntityList(List<Jugador> jugadores) {
        if (jugadores == null) {
            return List.of();
        }
        return jugadores.stream()
                .map(JugadorResponse::fromEntity)
                .collect(Collectors.toList());
    }
}

