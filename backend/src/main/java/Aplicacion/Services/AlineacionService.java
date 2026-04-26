package Aplicacion.Services;

import Dominio.Entity.Alineacion;
import Dominio.Entity.Partido;
import Dominio.Entity.Entrenador;
import Dominio.Entity.JugadorAlineacion;
import Dominio.Entity.Jugador;
import Dominio.Repositorys.AlineacionRepository;
import Dominio.Repositorys.PartidoRepository;
import Dominio.Repositorys.EntrenadorRepository;
import Dominio.Repositorys.JugadorRepository;
import Presentacion.DTOS.Alineacion.AlineacionesParaPartidoDTO;
import Presentacion.DTOS.Entrenador.AlineacionRequestDTO;
import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import Presentacion.DTOS.Partido.AlineacionParaActaDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
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
    private final EntrenadorRepository entrenadorRepository;
    private final JugadorRepository jugadorRepository;

    /**
     * Presentar una nueva alineación
     */
    @Transactional
    public AlineacionResponseDTO presentarAlineacion(AlineacionRequestDTO request, String username) {
        log.info("========================================");
        log.info("🏀 Presentando alineación para partido: {}", request.getPartidoId());
        log.info("   Entrenador: {}", username);

        // Buscar el entrenador
        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado"));

        // Buscar el partido
        Partido partido = partidoRepository.findById(request.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado"));

        // Verificar que el entrenador pertenece al equipo
        boolean esEntrenadorLocal = partido.getEquipoLocal().getEntrenador() != null &&
                partido.getEquipoLocal().getEntrenador().getId().equals(entrenador.getId());
        boolean esEntrenadorVisitante = partido.getEquipoVisitante().getEntrenador() != null &&
                partido.getEquipoVisitante().getEntrenador().getId().equals(entrenador.getId());

        if (!esEntrenadorLocal && !esEntrenadorVisitante) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No puedes presentar alineación para este partido");
        }

        // Determinar para qué equipo es la alineación
        Long equipoId = esEntrenadorLocal ?
                partido.getEquipoLocal().getId() : partido.getEquipoVisitante().getId();

        // Verificar si ya existe una alineación para este equipo en este partido
        alineacionRepository.findByPartidoIdAndEquipoId(request.getPartidoId(), equipoId)
                .ifPresent(a -> {
                    throw new ResponseStatusException(HttpStatus.CONFLICT,
                            "Ya existe una alineación para este equipo en este partido");
                });

        // Validar que la alineación tenga 5 titulares
        if (request.getTitulares() == null || request.getTitulares().size() != 5) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La alineación debe tener exactamente 5 jugadores titulares");
        }

        // Crear la alineación
        Alineacion alineacion = new Alineacion();
        alineacion.setPartido(partido);
        alineacion.setEquipo(esEntrenadorLocal ? partido.getEquipoLocal() : partido.getEquipoVisitante());
        alineacion.setEntrenador(entrenador);
        alineacion.setFechaPresentacion(LocalDateTime.now());
        alineacion.setConfirmada(request.isConfirmada());

        // Procesar jugadores
        List<JugadorAlineacion> jugadores = new ArrayList<>();

        // Procesar titulares
        for (var jugadorReq : request.getTitulares()) {
            Jugador jugador = jugadorRepository.findById(jugadorReq.getJugadorId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Jugador no encontrado: " + jugadorReq.getJugadorId()));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setJugador(jugador);
            ja.setNombreJugador(jugador.getNombre());
            ja.setApellidoJugador(jugador.getApellido());
            ja.setDorsal(jugadorReq.getDorsal());
            ja.setPosicion(jugadorReq.getPosicion());
            ja.setTitular(true);
            ja.setAlineacion(alineacion);
            jugadores.add(ja);
        }

        // Procesar suplentes
        if (request.getSuplentes() != null) {
            for (var jugadorReq : request.getSuplentes()) {
                Jugador jugador = jugadorRepository.findById(jugadorReq.getJugadorId())
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                                "Jugador no encontrado: " + jugadorReq.getJugadorId()));

                JugadorAlineacion ja = new JugadorAlineacion();
                ja.setJugador(jugador);
                ja.setNombreJugador(jugador.getNombre());
                ja.setApellidoJugador(jugador.getApellido());
                ja.setDorsal(jugadorReq.getDorsal());
                ja.setPosicion(jugadorReq.getPosicion());
                ja.setTitular(false);
                ja.setAlineacion(alineacion);
                jugadores.add(ja);
            }
        }

        alineacion.setJugadores(jugadores);
        Alineacion saved = alineacionRepository.save(alineacion);

        log.info("✅ Alineación guardada con ID: {}", saved.getId());
        log.info("   Titulares: {}", request.getTitulares().size());
        log.info("   Suplentes: {}", request.getSuplentes() != null ? request.getSuplentes().size() : 0);
        log.info("========================================");

        return AlineacionResponseDTO.fromEntity(saved);
    }

    /**
     * Obtener alineación por partido y equipo
     */
    @Transactional(readOnly = true)
    public AlineacionResponseDTO getAlineacion(Long partidoId, Long equipoId) {
        log.info("🔍 Buscando alineación para partido: {} y equipo: {}", partidoId, equipoId);

        Alineacion alineacion = alineacionRepository.findByPartidoIdAndEquipoId(partidoId, equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "No se encontró alineación para este equipo en el partido"));

        return AlineacionResponseDTO.fromEntity(alineacion);
    }

    /**
     * Obtener ambas alineaciones de un partido (para el árbitro)
     */
    @Transactional(readOnly = true)
    public AlineacionesParaPartidoDTO getAlineacionesPartido(Long partidoId) {
        log.info("🔍 Buscando alineaciones para partido: {}", partidoId);

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado"));

        Alineacion alineacionLocal = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoLocal().getId())
                .orElse(null);

        Alineacion alineacionVisitante = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoVisitante().getId())
                .orElse(null);

        AlineacionResponseDTO localDTO = alineacionLocal != null ?
                AlineacionResponseDTO.fromEntity(alineacionLocal) : null;
        AlineacionResponseDTO visitanteDTO = alineacionVisitante != null ?
                AlineacionResponseDTO.fromEntity(alineacionVisitante) : null;

        return AlineacionesParaPartidoDTO.fromEntities(
                localDTO,
                visitanteDTO,
                partidoId,
                partido.getEquipoLocal().getNombre(),
                partido.getEquipoVisitante().getNombre()
        );
    }

    /**
     * Confirmar una alineación (marcarla como definitiva)
     */
    @Transactional
    public AlineacionResponseDTO confirmarAlineacion(Long id, String username) {
        log.info("✅ Confirmando alineación ID: {} por entrenador: {}", id, username);

        Alineacion alineacion = alineacionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Alineación no encontrada"));

        // Verificar que el entrenador es el dueño de la alineación
        if (!alineacion.getEntrenador().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No puedes confirmar esta alineación");
        }

        alineacion.setConfirmada(true);
        Alineacion saved = alineacionRepository.save(alineacion);

        log.info("✅ Alineación confirmada: {}", id);

        return AlineacionResponseDTO.fromEntity(saved);
    }

    /**
     * Obtener alineaciones para el acta del árbitro
     */
    @Transactional(readOnly = true)
    public AlineacionParaActaDTO getAlineacionesParaActa(Long partidoId) {
        log.info("📋 Obteniendo alineaciones para acta del partido: {}", partidoId);

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado"));

        Alineacion alineacionLocal = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoLocal().getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Alineación local no encontrada"));

        Alineacion alineacionVisitante = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoVisitante().getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Alineación visitante no encontrada"));

        return AlineacionParaActaDTO.fromEntities(alineacionLocal, alineacionVisitante);
    }

    /**
     * Actualizar alineación (para entrenador)
     */
    @Transactional
    public AlineacionResponseDTO actualizarAlineacion(Long id, AlineacionRequestDTO request, String username) {
        log.info("✏️ Actualizando alineación ID: {}", id);

        Alineacion alineacion = alineacionRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Alineación no encontrada"));

        // Verificar permisos
        if (!alineacion.getEntrenador().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "No puedes modificar esta alineación");
        }

        // Si ya está confirmada, no se puede modificar
        if (alineacion.isConfirmada()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "No se puede modificar una alineación ya confirmada");
        }

        // Validar titulares
        if (request.getTitulares() == null || request.getTitulares().size() != 5) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La alineación debe tener exactamente 5 jugadores titulares");
        }

        // Limpiar jugadores existentes
        alineacion.getJugadores().clear();

        // Añadir nuevos jugadores
        List<JugadorAlineacion> nuevosJugadores = new ArrayList<>();

        for (var jugadorReq : request.getTitulares()) {
            Jugador jugador = jugadorRepository.findById(jugadorReq.getJugadorId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Jugador no encontrado"));

            JugadorAlineacion ja = new JugadorAlineacion();
            ja.setJugador(jugador);
            ja.setNombreJugador(jugador.getNombre());
            ja.setApellidoJugador(jugador.getApellido());
            ja.setDorsal(jugadorReq.getDorsal());
            ja.setPosicion(jugadorReq.getPosicion());
            ja.setTitular(true);
            ja.setAlineacion(alineacion);
            nuevosJugadores.add(ja);
        }

        if (request.getSuplentes() != null) {
            for (var jugadorReq : request.getSuplentes()) {
                Jugador jugador = jugadorRepository.findById(jugadorReq.getJugadorId())
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                                "Jugador no encontrado"));

                JugadorAlineacion ja = new JugadorAlineacion();
                ja.setJugador(jugador);
                ja.setNombreJugador(jugador.getNombre());
                ja.setApellidoJugador(jugador.getApellido());
                ja.setDorsal(jugadorReq.getDorsal());
                ja.setPosicion(jugadorReq.getPosicion());
                ja.setTitular(false);
                ja.setAlineacion(alineacion);
                nuevosJugadores.add(ja);
            }
        }

        alineacion.getJugadores().addAll(nuevosJugadores);
        alineacion.setFechaPresentacion(LocalDateTime.now());

        Alineacion saved = alineacionRepository.save(alineacion);
        log.info("✅ Alineación actualizada: {}", id);

        return AlineacionResponseDTO.fromEntity(saved);
    }
}