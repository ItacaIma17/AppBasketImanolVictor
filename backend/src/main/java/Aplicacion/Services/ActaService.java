package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.ActaPartidoRepository;
import Dominio.Repositorys.ArbitroRepository;
import Dominio.Repositorys.JugadorRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Arbitro.ActaRequestDTO;
import Presentacion.DTOS.Arbitro.ActaResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActaService {

    private final ActaPartidoRepository actaRepository;
    private final PartidoRepository partidoRepository;
    private final ArbitroRepository arbitroRepository;
    private final JugadorRepository jugadorRepository;

    @Transactional
    public ActaResponseDTO guardarActa(ActaRequestDTO request, String emailArbitro) {
        log.info("Guardando acta para partido: {}", request.getPartidoId());

        // Validar partido
        Partido partido = partidoRepository.findById(request.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        // Validar árbitro
        Arbitro arbitro = arbitroRepository.findByEmail(emailArbitro)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Árbitro no encontrado"));

        // Verificar si ya existe acta
        if (actaRepository.existsByPartido(partido)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Ya existe un acta para este partido");
        }

        // Crear acta
        ActaPartido acta = new ActaPartido();
        acta.setPartido(partido);
        acta.setArbitro(arbitro);
        acta.setFechaActa(LocalDateTime.now());
        acta.setResultadoLocal(request.getResultadoLocal());
        acta.setResultadoVisitante(request.getResultadoVisitante());
        acta.setObservaciones(request.getObservaciones());

        List<EventoPartido> eventos = new ArrayList<>();

        for (ActaRequestDTO.EventoDTO eventoDTO : request.getEventos()) {
            EventoPartido evento = new EventoPartido();
            evento.setActa(acta);
            evento.setMinuto(eventoDTO.getMinuto());
            evento.setTipo(TipoEevento.valueOf(eventoDTO.getTipo()));
            evento.setDescripcion(eventoDTO.getDescripcion());
            evento.setNombreJugador(eventoDTO.getNombreJugador());
            evento.setNombreEquipo(eventoDTO.getNombreEquipo());

            if (eventoDTO.getJugadorId() != null) {
                Jugador jugador = jugadorRepository.findById(eventoDTO.getJugadorId()).orElse(null);
                evento.setJugador(jugador);
            }

            eventos.add(evento);
        }

        acta.setEventos(eventos);
        acta = actaRepository.save(acta);

        log.info("Acta guardada con ID: {}", acta.getId());

        return toResponse(acta);
    }

    public ActaResponseDTO obtenerActa(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        ActaPartido acta = actaRepository.findByPartido(partido)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Acta no encontrada"));

        return toResponse(acta);
    }

    private ActaResponseDTO toResponse(ActaPartido acta) {
        ActaResponseDTO response = new ActaResponseDTO();
        response.setId(acta.getId());
        response.setPartidoId(acta.getPartido().getId());
        response.setEquipoLocal(acta.getPartido().getEquipoLocal().getNombre());
        response.setEquipoVisitante(acta.getPartido().getEquipoVisitante().getNombre());
        response.setResultadoLocal(acta.getResultadoLocal());
        response.setResultadoVisitante(acta.getResultadoVisitante());
        response.setFecha(LocalTime.parse(acta.getPartido().getFecha().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))));
        response.setHora(LocalDate.from(acta.getPartido().getHora()));
        response.setPabellon(acta.getPartido().getPabellon());
        response.setObservaciones(acta.getObservaciones());
        response.setArbitroNombre(acta.getArbitro().getNombre() + " " + acta.getArbitro().getApellidos());

        List<ActaResponseDTO.EventoResponseDTO> eventos = acta.getEventos().stream()
                .map(e -> {
                    ActaResponseDTO.EventoResponseDTO dto = new ActaResponseDTO.EventoResponseDTO();
                    dto.setId(e.getId());
                    dto.setJugadorNombre(e.getNombreJugador());
                    dto.setEquipoNombre(e.getNombreEquipo());
                    dto.setMinuto(e.getMinuto());
                    dto.setTipo(e.getTipo());
                    dto.setDescripcion(e.getDescripcion());
                    return dto;
                })
                .collect(Collectors.toList());

        response.setEventos(eventos);

        return response;
    }
}
