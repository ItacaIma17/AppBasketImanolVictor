package Aplicacion.Services;


import Dominio.Entity.*;
import Dominio.Repositorys.*;
import Presentacion.DTOS.Entrenador.AlineacionRequestDTO;
import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AlineacionService {

    private final AlineacionRepository alineacionRepository;
    private final PartidoRepository partidoRepository;
    private final EquipoRepository equipoRepository;
    private final JugadorRepository jugadorRepository;
    private final EntrenadorRepository entrenadorRepository;

    @Transactional
    public AlineacionResponseDTO guardarAlineacion(AlineacionRequestDTO request, String emailEntrenador) {
        log.info("Guardando alineación para partido: {}", request.getPartidoId());

        // Validar partido
        Partido partido = partidoRepository.findById(request.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        // Validar entrenador
        Entrenador entrenador = entrenadorRepository.findByEmail(emailEntrenador)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Entrenador no encontrado"));

        // Obtener equipo del entrenador
        Equipo equipo = entrenador.getEquipo();
        if (equipo == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El entrenador no tiene equipo asignado");
        }

        // Validar que el equipo participa en el partido
        if (!partido.getEquipoLocal().equals(equipo) && !partido.getEquipoVisitante().equals(equipo)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Este equipo no participa en el partido");
        }

        // Verificar si ya existe alineación
        if (alineacionRepository.existsByPartidoAndEquipo(partido, equipo)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe una alineación para este partido");
        }

        // Validar que hay exactamente 5 titulares
        if (request.getTitulares().size() != 5) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Debe haber exactamente 5 jugadores titulares");
        }

        // Crear alineación
        Alineacion alineacion = new Alineacion();
        alineacion.setPartido(partido);
        alineacion.setEquipo(equipo);
        alineacion.setEntrenador(entrenador);
        alineacion.setFechaPresentacion(LocalDateTime.now());
        alineacion.setConfirmada(true);

        List<JugadorAlineacion> jugadoresAlineacion = new ArrayList<>();

        // Agregar titulares
        for (Long jugadorId : request.getTitulares()) {
            Jugador jugador = jugadorRepository.findById(jugadorId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Jugador no encontrado: " + jugadorId));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setAlineacion(alineacion);
            ja.setJugador(jugador);
            ja.setTitular(true);
            ja.setDorsal(jugador.getDorsal());
            ja.setPosicion(jugador.getPosicion());
            jugadoresAlineacion.add(ja);
        }

        // Agregar suplentes
        for (Long jugadorId : request.getSuplentes()) {
            Jugador jugador = jugadorRepository.findById(jugadorId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Jugador no encontrado: " + jugadorId));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setAlineacion(alineacion);
            ja.setJugador(jugador);
            ja.setTitular(false);
            ja.setDorsal(jugador.getDorsal());
            ja.setPosicion(jugador.getPosicion());
            jugadoresAlineacion.add(ja);
        }

        alineacion.setJugadores(jugadoresAlineacion);
        alineacion = alineacionRepository.save(alineacion);

        log.info("Alineación guardada con ID: {}", alineacion.getId());

        return toResponse(alineacion);
    }

    public AlineacionResponseDTO obtenerAlineacion(Long partidoId, String emailEntrenador) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        Entrenador entrenador = entrenadorRepository.findByEmail(emailEntrenador)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Entrenador no encontrado"));

        Equipo equipo = entrenador.getEquipo();

        Alineacion alineacion = alineacionRepository.findByPartidoAndEquipo(partido, equipo)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Alineación no encontrada"));

        return toResponse(alineacion);
    }

    private AlineacionResponseDTO toResponse(Alineacion alineacion) {
        AlineacionResponseDTO response = new AlineacionResponseDTO();
        response.setId(alineacion.getId());
        response.setPartidoId(alineacion.getPartido().getId());
        response.setEquipoId(alineacion.getEquipo().getId());
        response.setEquipoNombre(alineacion.getEquipo().getNombre());
        response.setConfirmada(alineacion.isConfirmada());

        List<AlineacionResponseDTO.JugadorAlineacionDTO> titulares = new ArrayList<>();
        List<AlineacionResponseDTO.JugadorAlineacionDTO> suplentes = new ArrayList<>();

        for (JugadorAlineacion ja : alineacion.getJugadores()) {
            AlineacionResponseDTO.JugadorAlineacionDTO dto = new AlineacionResponseDTO.JugadorAlineacionDTO();
            dto.setId(ja.getJugador().getId());
            dto.setNombre(ja.getJugador().getNombre());
            dto.setApellido(ja.getJugador().getApellido());
            dto.setDorsal(ja.getDorsal());
            dto.setPosicion(ja.getPosicion());

            if (ja.isTitular()) {
                titulares.add(dto);
            } else {
                suplentes.add(dto);
            }
        }

        response.setTitulares(titulares);
        response.setSuplentes(suplentes);

        return response;
    }
}
