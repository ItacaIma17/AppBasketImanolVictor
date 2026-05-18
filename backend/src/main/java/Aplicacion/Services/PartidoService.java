package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.*;
import Dominio.Repositorys.AlineacionRepository;
import Presentacion.DTOS.Partido.CrearPartidoCompletoDTO;
import Presentacion.DTOS.Partido.PartidoRequestDTO;
import Presentacion.DTOS.Partido.PartidoResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class PartidoService {

    private final PartidoRepository partidoRepository;
    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;
    private final EntrenadorRepository entrenadorRepository;
    private final ArbitroRepository arbitroRepository;
    private final JugadorRepository jugadorRepository;
    private final ActaPartidoRepository actaPartidoRepository;
    private final AlineacionRepository alineacionRepository;

    @Transactional
    public PartidoResponse crearPartido(PartidoRequestDTO dto) {
        log.info("========================================");
        log.info(" Creando partido:");
        log.info("   Equipo Local ID: {}", dto.getEquipoLocalId());
        log.info("   Equipo Visitante ID: {}", dto.getEquipoVisitanteId());
        log.info("   Fecha: {}", dto.getFecha());
        log.info("   Ubicación: {}", dto.getUbicacion());
        log.info("   Liga ID: {}", dto.getLigaId());

        if (dto.getEquipoLocalId() == null || dto.getEquipoVisitanteId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Los equipos local y visitante son obligatorios");
        }

        Equipo equipoLocal = equipoRepository.findById(dto.getEquipoLocalId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo local no encontrado con ID: " + dto.getEquipoLocalId()));

        Equipo equipoVisitante = equipoRepository.findById(dto.getEquipoVisitanteId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo visitante no encontrado con ID: " + dto.getEquipoVisitanteId()));

        if (dto.getJornada() == null || dto.getJornada() < 1 || dto.getJornada() > 34) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La jornada debe ser entre 1 y 34");
        }

        boolean existeEnJornada = partidoRepository.existsByEquiposAndJornada(
                equipoLocal.getId(), equipoVisitante.getId(), dto.getJornada());
        if (existeEnJornada) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un partido entre estos equipos en la jornada " + dto.getJornada());
        }

        if (equipoLocal.getId().equals(equipoVisitante.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Un equipo no puede jugar contra sí mismo");
        }

        if (dto.getFecha() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La fecha del partido es obligatoria");
        }

        if (dto.getFecha().isBefore(LocalDateTime.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La fecha del partido no puede ser en el pasado");
        }

        boolean existe = partidoRepository.existsPartidoEntreEquipos(
                equipoLocal.getId(), equipoVisitante.getId());
        if (existe) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un partido programado entre estos equipos");
        }

        Partido partido = new Partido();
        partido.setEquipoLocal(equipoLocal);
        partido.setEquipoVisitante(equipoVisitante);
        partido.setFecha(dto.getFecha());
        partido.setUbicacion(dto.getUbicacion());
        partido.setJornada(dto.getJornada());
        partido.setEstado("PROGRAMADO");

        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada con ID: " + dto.getLigaId()));
            partido.setLiga(liga);
        }

        Partido saved = partidoRepository.save(partido);
        log.info(" Partido creado con ID: {}", saved.getId());
        log.info("========================================");

        return PartidoResponse.fromEntity(saved);
    }

    @Transactional
    public List<PartidoResponse> crearPartidosConJornadas(CrearPartidoCompletoDTO dto) {
        log.info(" Creando partidos con jornadas");
        List<Partido> partidosCreados = new ArrayList<>();

        Equipo equipoLocal = equipoRepository.findById(dto.getEquipoLocalId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo local no encontrado"));
        Equipo equipoVisitante = equipoRepository.findById(dto.getEquipoVisitanteId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Equipo visitante no encontrado"));

        if (equipoLocal.getId().equals(equipoVisitante.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Un equipo no puede jugar contra sí mismo");
        }

        Partido partidoIda = new Partido();
        partidoIda.setEquipoLocal(equipoLocal);
        partidoIda.setEquipoVisitante(equipoVisitante);
        partidoIda.setFecha(dto.getFechaIda());
        partidoIda.setPabellon(dto.getPabellonIda());
        partidoIda.setUbicacion(dto.getUbicacionIda() != null ? dto.getUbicacionIda() : dto.getPabellonIda());
        partidoIda.setJornada(dto.getJornadaIda());
        partidoIda.setEstado("PROGRAMADO");

        if (dto.getArbitroId() != null) {
            Arbitro arbitroIda = arbitroRepository.findById(dto.getArbitroId()).orElse(null);
            if (arbitroIda != null) {
                partidoIda.setArbitro(arbitroIda);
            }
        }

        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Liga no encontrada"));
            partidoIda.setLiga(liga);
        }

        partidosCreados.add(partidoRepository.save(partidoIda));
        log.info(" Partido de ida creado - Jornada: {}", dto.getJornadaIda());

        if (dto.isCrearVuelta()) {
            Partido partidoVuelta = new Partido();
            partidoVuelta.setEquipoLocal(equipoVisitante);
            partidoVuelta.setEquipoVisitante(equipoLocal);

            if (dto.getFechaVuelta() != null) {
                partidoVuelta.setFecha(dto.getFechaVuelta());
            } else if (dto.getDiferenciaJornadas() != null) {

                partidoVuelta.setFecha(dto.getFechaIda().plusDays(dto.getDiferenciaJornadas() * 7L));
            } else {
                partidoVuelta.setFecha(dto.getFechaIda().plusDays(77));
            }

            String pabellonVuelta = dto.getPabellonVuelta();
            if (pabellonVuelta == null || pabellonVuelta.isBlank()) {

                pabellonVuelta = equipoVisitante.getNombreEstadio() != null && !equipoVisitante.getNombreEstadio().isBlank()
                        ? equipoVisitante.getNombreEstadio()
                        : dto.getPabellonIda();
            }
            String ubicacionVuelta = dto.getUbicacionVuelta();
            if (ubicacionVuelta == null || ubicacionVuelta.isBlank()) {
                ubicacionVuelta = equipoVisitante.getCiudad() != null ? equipoVisitante.getCiudad() : dto.getUbicacionIda();
            }
            partidoVuelta.setPabellon(pabellonVuelta);
            partidoVuelta.setUbicacion(ubicacionVuelta);
            partidoVuelta.setJornada(dto.getJornadaVuelta() != null ? dto.getJornadaVuelta() : dto.getJornadaIda() + 11);
            partidoVuelta.setEstado("PROGRAMADO");

            if (dto.getArbitroId() != null) {
                Arbitro arbitroVuelta = arbitroRepository.findById(dto.getArbitroId()).orElse(null);
                if (arbitroVuelta != null) {
                    partidoVuelta.setArbitro(arbitroVuelta);
                }
            }

            if (dto.getLigaId() != null) {
                Liga liga = ligaRepository.findById(dto.getLigaId()).orElse(null);
                partidoVuelta.setLiga(liga);
            }

            partidosCreados.add(partidoRepository.save(partidoVuelta));
            log.info(" Partido de vuelta creado - Jornada: {}", partidoVuelta.getJornada());
        }

        return partidosCreados.stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getPartidosByJugador(String username) {
        log.info(" Buscando partidos para jugador: {}", username);

        Jugador jugador = jugadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Jugador no encontrado: " + username));

        if (jugador.getEquipo() == null) {
            log.warn("Jugador {} no tiene equipo asignado", username);
            return List.of();
        }

        Long equipoId = jugador.getEquipo().getId();
        log.info("Jugador {} tiene equipo ID: {}", username, equipoId);

        return getPartidosByEquipo(equipoId);
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getProximosPartidosByJugador(String username) {
        log.info(" Buscando próximos partidos para jugador: {}", username);

        Jugador jugador = jugadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Jugador no encontrado: " + username));

        if (jugador.getEquipo() == null) {
            log.warn("Jugador {} no tiene equipo asignado", username);
            return List.of();
        }

        Long equipoId = jugador.getEquipo().getId();
        return getProximosPartidosByEquipo(equipoId);
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> listarTodosPartidos() {
        log.info(" Listando todos los partidos");
        return partidoRepository.findAll().stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> listarPartidosPorEstado(String estado) {
        log.info(" Listando partidos con estado: {}", estado);
        return partidoRepository.findByEstado(estado).stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> listarPartidosPendientes() {
        log.info(" Listando partidos pendientes");
        return partidoRepository.findPartidosPendientes().stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> listarPartidosFuturos() {
        log.info(" Listando partidos futuros");
        return partidoRepository.findPartidosFuturos(LocalDateTime.now()).stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getPartidosByEquipoAndEstado(Long equipoId, String estado) {
        log.info(" Buscando partidos para equipo ID: {} con estado: {}", equipoId, estado);

        if (!equipoRepository.existsById(equipoId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Equipo no encontrado con ID: " + equipoId);
        }

        return partidoRepository.findByEquipoIdAndEstado(equipoId, estado).stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getProximosPartidosByEquipo(Long equipoId) {
        log.info(" Buscando próximos partidos para equipo ID: {}", equipoId);

        if (!equipoRepository.existsById(equipoId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Equipo no encontrado con ID: " + equipoId);
        }

        return partidoRepository.findProximosPartidosByEquipo(equipoId, LocalDateTime.now()).stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getPartidosByEntrenador(String username) {
        log.info(" Buscando partidos para entrenador: {}", username);

        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado: " + username));

        if (entrenador.getEquipo() == null) {
            log.warn("Entrenador {} no tiene equipo asignado", username);
            return List.of();
        }

        Long equipoId = entrenador.getEquipo().getId();
        log.info("Entrenador {} tiene equipo ID: {}", username, equipoId);

        return partidoRepository.findByEquipoLocalIdOrEquipoVisitanteId(equipoId).stream()
                .map(p -> {
                    PartidoResponse r = PartidoResponse.fromEntity(p);
                    if (p.getEquipoLocal() != null) {
                        var alLocal = alineacionRepository.findByPartidoIdAndEquipoId(p.getId(), p.getEquipoLocal().getId());
                        r.setTieneAlineacionLocal(alLocal.isPresent());
                        r.setAlineacionLocalConfirmada(alLocal.map(a -> a.isConfirmada()).orElse(false));
                    }
                    if (p.getEquipoVisitante() != null) {
                        var alVis = alineacionRepository.findByPartidoIdAndEquipoId(p.getId(), p.getEquipoVisitante().getId());
                        r.setTieneAlineacionVisitante(alVis.isPresent());
                        r.setAlineacionVisitanteConfirmada(alVis.map(a -> a.isConfirmada()).orElse(false));
                    }
                    return r;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getProximosPartidosByEntrenador(String username) {
        log.info(" Buscando próximos partidos para entrenador: {}", username);

        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado: " + username));

        if (entrenador.getEquipo() == null) {
            log.warn("Entrenador {} no tiene equipo asignado", username);
            return List.of();
        }

        Long equipoId = entrenador.getEquipo().getId();
        return getProximosPartidosByEquipo(equipoId);
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getPartidosByArbitro(String username) {
        log.info(" Buscando partidos para árbitro: {}", username);

        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado: " + username));

        List<Partido> partidos = partidoRepository.findByArbitroId(arbitro.getId());

        return partidos.stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public PartidoResponse getPartidoById(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));
        return PartidoResponse.fromEntity(partido);
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getPartidosByLiga(Long ligaId) {
        log.info(" Buscando partidos para liga ID: {}", ligaId);

        if (!ligaRepository.existsById(ligaId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Liga no encontrada con ID: " + ligaId);
        }

        return partidoRepository.findByLigaId(ligaId).stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public PartidoResponse obtenerPartidoPorId(Long id) {
        log.info(" Buscando partido con ID: {}", id);

        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + id));

        return PartidoResponse.fromEntity(partido);
    }

    @Transactional
    public PartidoResponse actualizarPartido(Long id, PartidoRequestDTO dto) {
        log.info(" Actualizando partido ID: {}  payload={}", id, dto);

        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + id));

        if ("FINALIZADO".equals(partido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "No se puede modificar un partido finalizado");
        }

        if (dto.getEquipoLocalId() != null) {
            Equipo equipoLocal = equipoRepository.findById(dto.getEquipoLocalId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Equipo local no encontrado"));
            partido.setEquipoLocal(equipoLocal);
        }

        if (dto.getEquipoVisitanteId() != null) {
            Equipo equipoVisitante = equipoRepository.findById(dto.getEquipoVisitanteId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Equipo visitante no encontrado"));
            partido.setEquipoVisitante(equipoVisitante);
        }

        if (dto.getFecha() != null) {

            if ("PROGRAMADO".equals(partido.getEstado())
                    && dto.getFecha().isBefore(LocalDateTime.now())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "La fecha del partido no puede ser en el pasado");
            }
            partido.setFecha(dto.getFecha());
        }

        if (dto.getUbicacion() != null) {
            partido.setUbicacion(dto.getUbicacion());
        }

        if (dto.getPabellon() != null) {
            partido.setPabellon(dto.getPabellon());
        }

        if (dto.getJornada() != null) {
            if (dto.getJornada() < 1 || dto.getJornada() > 34) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "La jornada debe estar entre 1 y 34");
            }
            partido.setJornada(dto.getJornada());
        }

        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada"));
            partido.setLiga(liga);
        }

        if (dto.getArbitroId() != null) {
            Arbitro arbitro = arbitroRepository.findById(dto.getArbitroId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Árbitro no encontrado con ID: " + dto.getArbitroId()));
            partido.setArbitro(arbitro);
        }

        if (dto.getEstado() != null && !dto.getEstado().isBlank()) {
            partido.setEstado(dto.getEstado());
        }

        Partido saved = partidoRepository.save(partido);
        log.info(" Partido actualizado: {}", saved.getId());

        return PartidoResponse.fromEntity(saved);
    }

    @Transactional
    public PartidoResponse actualizarResultado(Long partidoId, Map<String, Integer> resultado) {
        log.info(" Actualizando resultado del partido ID: {}", partidoId);

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + partidoId));

        Integer resultadoLocal = resultado.get("resultadoLocal");
        Integer resultadoVisitante = resultado.get("resultadoVisitante");

        if (resultadoLocal == null || resultadoVisitante == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Debe proporcionar ambos resultados");
        }

        partido.setResultadoLocal(resultadoLocal);
        partido.setResultadoVisitante(resultadoVisitante);
        partido.setEstado("FINALIZADO");

        Partido saved = partidoRepository.save(partido);
        log.info(" Resultado actualizado: {} - {}", resultadoLocal, resultadoVisitante);

        return PartidoResponse.fromEntity(saved);
    }

        @Transactional
        public PartidoResponse asignarArbitro(Long partidoId, Long arbitroId) {
            log.info(" Asignando árbitro ID: {} al partido ID: {}", arbitroId, partidoId);

            Partido partido = partidoRepository.findById(partidoId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Partido no encontrado con ID: " + partidoId));

            Arbitro arbitro = arbitroRepository.findById(arbitroId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Árbitro no encontrado con ID: " + arbitroId));

            if (partido.getEstado().equals("FINALIZADO")) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "No se puede asignar árbitro a un partido finalizado");
            }

            partido.setArbitro(arbitro);
            Partido saved = partidoRepository.save(partido);
            log.info(" Árbitro {} asignado al partido {}", arbitro.getNombre(), saved.getId());

            return PartidoResponse.fromEntity(saved);
        }

    @Transactional
    public void eliminarPartido(Long id) {
        log.info(" Eliminando partido ID: {}", id);

        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + id));

        if (partido.getEstado().equals("FINALIZADO")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "No se puede eliminar un partido finalizado");
        }

        partidoRepository.deleteById(id);
        log.info(" Partido eliminado: {}", id);
    }

    @Transactional
    public PartidoResponse cambiarEstado(Long partidoId, String nuevoEstado) {
        log.info(" Cambiando estado del partido ID: {} a {}", partidoId, nuevoEstado);

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + partidoId));

        if (!nuevoEstado.equals("PROGRAMADO") &&
                !nuevoEstado.equals("EN_CURSO") &&
                !nuevoEstado.equals("FINALIZADO") &&
                !nuevoEstado.equals("CANCELADO")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Estado no válido: " + nuevoEstado);
        }

        partido.setEstado(nuevoEstado);
        Partido saved = partidoRepository.save(partido);
        log.info(" Estado del partido {} cambiado a {}", saved.getId(), nuevoEstado);

        return PartidoResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getPartidosByEquipo(Long equipoId) {
        log.info(" Buscando partidos para equipo ID: {}", equipoId);

        if (!equipoRepository.existsById(equipoId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Equipo no encontrado con ID: " + equipoId);
        }

        return partidoRepository.findByEquipoLocalIdOrEquipoVisitanteId(equipoId).stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getDetalleCompletoPartido(Long partidoId) {
        log.info(" Obteniendo detalle completo del partido: {}", partidoId);

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + partidoId));

        ActaPartido acta = actaPartidoRepository.findByPartidoId(partidoId).orElse(null);

        Map<String, Object> detalle = new HashMap<>();
        detalle.put("partido", PartidoResponse.fromEntity(partido));
        detalle.put("estado", partido.getEstado());
        detalle.put("tieneActa", acta != null);
        detalle.put("resultadoFinal", acta != null ?
                acta.getResultadoLocal() + " - " + acta.getResultadoVisitante() : "Pendiente");
        detalle.put("fechaFormateada", partido.getFecha().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));

        if (partido.getEquipoLocal() != null) {
            detalle.put("equipoLocal", Map.of(
                    "id", partido.getEquipoLocal().getId(),
                    "nombre", partido.getEquipoLocal().getNombre(),
                    "escudo", partido.getEquipoLocal().getEscudoUrl() != null ? partido.getEquipoLocal().getEscudoUrl() : ""
            ));
        }
        if (partido.getEquipoVisitante() != null) {
            detalle.put("equipoVisitante", Map.of(
                    "id", partido.getEquipoVisitante().getId(),
                    "nombre", partido.getEquipoVisitante().getNombre(),
                    "escudo", partido.getEquipoVisitante().getEscudoUrl() != null ? partido.getEquipoVisitante().getEscudoUrl() : ""
            ));
        }

        if (partido.getArbitro() != null) {
            detalle.put("arbitro", Map.of(
                    "id", partido.getArbitro().getId(),
                    "nombre", partido.getArbitro().getNombre(),
                    "apellidos", partido.getArbitro().getApellidos()
            ));
        }

        return detalle;
    }

    @Transactional
    public PartidoResponse finalizarPartido(Long partidoId, int resultadoLocal, int resultadoVisitante) {
        log.info(" Finalizando partido ID: {} - Resultado: {} - {}", partidoId, resultadoLocal, resultadoVisitante);

        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + partidoId));

        if ("FINALIZADO".equals(partido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El partido ya está finalizado");
        }

        partido.setResultadoLocal(resultadoLocal);
        partido.setResultadoVisitante(resultadoVisitante);
        partido.setEstado("FINALIZADO");

        actualizarEstadisticasEquipo(partido.getEquipoLocal().getId(), resultadoLocal, resultadoVisitante);
        actualizarEstadisticasEquipo(partido.getEquipoVisitante().getId(), resultadoVisitante, resultadoLocal);

        return PartidoResponse.fromEntity(partidoRepository.save(partido));
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getHistorialEquipo(Long equipoId) {
        log.info(" Obteniendo historial del equipo: {}", equipoId);

        List<Partido> partidos = partidoRepository.findByEquipoLocalIdOrEquipoVisitanteId(equipoId);

        int ganados = 0;
        int perdidos = 0;
        int empatados = 0;
        int puntosFavor = 0;
        int puntosContra = 0;

        for (Partido p : partidos) {
            if (p.getEstado() == null || !"FINALIZADO".equals(p.getEstado())) continue;

            if (p.getEquipoLocal() == null || p.getEquipoVisitante() == null) continue;
            boolean esLocal = p.getEquipoLocal().getId().equals(equipoId);
            int puntosEquipo = esLocal ? p.getResultadoLocal() : p.getResultadoVisitante();
            int puntosRival = esLocal ? p.getResultadoVisitante() : p.getResultadoLocal();

            puntosFavor += puntosEquipo;
            puntosContra += puntosRival;

            if (puntosEquipo > puntosRival) ganados++;
            else if (puntosEquipo < puntosRival) perdidos++;
            else empatados++;
        }

        Map<String, Object> historial = new HashMap<>();
        historial.put("equipoId", equipoId);
        historial.put("totalPartidos", partidos.size());
        historial.put("partidosFinalizados", partidos.stream().filter(p -> "FINALIZADO".equals(p.getEstado())).count());
        historial.put("ganados", ganados);
        historial.put("perdidos", perdidos);
        historial.put("empatados", empatados);
        historial.put("puntosFavor", puntosFavor);
        historial.put("puntosContra", puntosContra);
        historial.put("diferenciaPuntos", puntosFavor - puntosContra);
        historial.put("ultimosPartidos", partidos.stream()
                .sorted((a, b) -> b.getFecha().compareTo(a.getFecha()))
                .limit(5)
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList()));

        return historial;
    }

    private void actualizarEstadisticasEquipo(Long equipoId, int puntosFavor, int puntosContra) {
        Equipo equipo = equipoRepository.findById(equipoId).orElse(null);
        if (equipo == null) return;

        equipo.setPuntosFavor(equipo.getPuntosFavor() + puntosFavor);
        equipo.setPuntosContra(equipo.getPuntosContra() + puntosContra);

        if (puntosFavor > puntosContra) {
            equipo.setVictorias(equipo.getVictorias() + 1);
        } else if (puntosFavor < puntosContra) {
            equipo.setDerrotas(equipo.getDerrotas() + 1);
        }

        equipoRepository.save(equipo);
    }
}
