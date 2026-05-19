package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.*;
import jakarta.mail.MessagingException;
import Presentacion.DTOS.Equipo.EquipoRequest;
import Presentacion.DTOS.Equipo.EquipoResponse;
import Presentacion.DTOS.Equipo.SolicitarEquipoDTO;
import Presentacion.DTOS.Equipo.AprobarSolicitudDTO;
import Presentacion.DTOS.Jugador.JugadorResponse;
import Presentacion.DTOS.Partido.PartidoResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EquipoService {

    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;
    private final EntrenadorRepository entrenadorRepository;
    private final JugadorRepository jugadorRepository;

    private static final String CODIGO_PREFIX = "EQ-";
    private static final SecureRandom random = new SecureRandom();

    private final PartidoRepository partidoRepository;
    private final EmailService emailService;

    private String generarCodigoSolicitud() {
        String codigo;
        do {
            int numero = 100000 + random.nextInt(900000);
            codigo = CODIGO_PREFIX + numero;
        } while (equipoRepository.findByCodigoSolicitud(codigo).isPresent());
        return codigo;
    }

    @Transactional
    public EquipoResponse crearEquipo(EquipoRequest dto) {
        log.info(" Creando equipo: {}", dto.getNombre());

        if (equipoRepository.findByNombre(dto.getNombre()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un equipo con ese nombre");
        }

        Liga liga = null;
        if (dto.getLigaId() != null) {
            liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada con ID: " + dto.getLigaId()));
        }

        Equipo equipo = dto.toEntity();
        equipo.setLiga(liga);
        equipo.setCodigoSolicitud(generarCodigoSolicitud());
        equipo.setSolicitudPendiente(false);

        Equipo saved = equipoRepository.save(equipo);
        log.info(" Equipo creado con ID: {} y código: {}", saved.getId(), saved.getCodigoSolicitud());

        return EquipoResponse.fromEntity(saved);
    }

    @Transactional
    public void solicitarDirigirEquipo(String username, SolicitarEquipoDTO dto) {
        log.info("========================================");
        log.info(" Solicitud de equipo para entrenador: {}", username);
        log.info("   Código de solicitud: {}", dto.getCodigoSolicitud());

        if (username == null || username.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Username del entrenador no proporcionado");
        }

        if (dto.getCodigoSolicitud() == null || dto.getCodigoSolicitud().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Código de solicitud no proporcionado");
        }

        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> {
                    log.error(" Entrenador no encontrado con username: {}", username);
                    return new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Entrenador no encontrado con username: " + username);
                });

        log.info(" Entrenador encontrado:");
        log.info("   ID: {}", entrenador.getId());
        log.info("   Nombre: {} {}", entrenador.getNombre(), entrenador.getApellido());
        log.info("   Username: {}", entrenador.getUsername());

        if (entrenador.getEquipo() != null) {
            log.warn(" El entrenador ya tiene un equipo asignado: {}", entrenador.getEquipo().getNombre());
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya tienes un equipo asignado: " + entrenador.getEquipo().getNombre());
        }

        Equipo equipo = equipoRepository.findByCodigoSolicitud(dto.getCodigoSolicitud())
                .orElseThrow(() -> {
                    log.error(" Equipo no encontrado con código: {}", dto.getCodigoSolicitud());
                    return new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Código de equipo inválido: " + dto.getCodigoSolicitud());
                });

        log.info(" Equipo encontrado:");
        log.info("   ID: {}", equipo.getId());
        log.info("   Nombre: {}", equipo.getNombre());
        log.info("   Entrenador actual: {}", equipo.getEntrenador() != null ? equipo.getEntrenador().getNombre() : "ninguno");

        if (equipo.getEntrenador() != null) {
            log.warn(" El equipo {} ya tiene un entrenador asignado: {}",
                    equipo.getNombre(), equipo.getEntrenador().getNombre());
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este equipo ya tiene un entrenador asignado");
        }

        if (equipo.getSolicitudPendiente() != null && equipo.getSolicitudPendiente()) {
            log.warn(" El equipo {} ya tiene una solicitud pendiente", equipo.getNombre());
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya hay una solicitud pendiente para este equipo");
        }

        equipo.setSolicitudPendiente(true);
        equipo.setEntrenadorSolicitanteId(entrenador.getId());
        equipoRepository.save(equipo);

        log.info(" Solicitud registrada exitosamente:");
        log.info("   Entrenador: {} {}", entrenador.getNombre(), entrenador.getApellido());
        log.info("   Equipo: {}", equipo.getNombre());
        log.info("   Estado: PENDIENTE");
        log.info("========================================");
    }

    @Transactional
    public EquipoResponse aprobarSolicitud(AprobarSolicitudDTO dto, String adminUsername) {
        log.info(" Admin {} procesando solicitud para equipo código: {}",
                adminUsername, dto.getCodigoSolicitud());

        Equipo equipo = equipoRepository.findByCodigoSolicitud(dto.getCodigoSolicitud())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Código de equipo inválido: " + dto.getCodigoSolicitud()));

        if (!Boolean.TRUE.equals(equipo.getSolicitudPendiente())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "No hay solicitud pendiente para este equipo");
        }

        Entrenador entrenador = entrenadorRepository.findById(dto.getEntrenadorId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con ID: " + dto.getEntrenadorId()));

        if (dto.getAprobar()) {

            entrenador.setEquipo(equipo);
            equipo.setEntrenador(entrenador);
            equipo.setSolicitudPendiente(false);
            equipo.setEntrenadorSolicitanteId(null);

            entrenadorRepository.save(entrenador);
            equipoRepository.save(equipo);

            log.info(" Solicitud APROBADA: Entrenador {} asignado a equipo {}",
                    entrenador.getUsername(), equipo.getNombre());

            try {
                emailService.enviarSolicitudAprobada(
                        entrenador.getEmail(), entrenador.getNombre(), equipo.getNombre());
            } catch (MessagingException e) {
                log.warn("Email de aprobación no enviado al entrenador {}: {}", entrenador.getEmail(), e.getMessage());
            }
        } else {

            equipo.setSolicitudPendiente(false);
            equipo.setEntrenadorSolicitanteId(null);
            equipoRepository.save(equipo);

            log.info(" Solicitud RECHAZADA para entrenador {} en equipo {}",
                    entrenador.getUsername(), equipo.getNombre());

            try {
                emailService.enviarSolicitudRechazada(
                        entrenador.getEmail(), entrenador.getNombre(), equipo.getNombre());
            } catch (MessagingException e) {
                log.warn("Email de rechazo no enviado al entrenador {}: {}", entrenador.getEmail(), e.getMessage());
            }
        }

        return EquipoResponse.fromEntity(equipo);
    }

    public List<EquipoResponse> listarPorLiga(Long ligaId) {
        return equipoRepository.findAll().stream()
                .filter(e -> e.getLiga() != null && ligaId.equals(e.getLiga().getId()))
                .map(this::toResponse)
                .toList();
    }

    private EquipoResponse toResponse(Equipo equipo) {
        return EquipoResponse.fromEntity(equipo);
    }

    @Transactional(readOnly = true)
    public List<JugadorResponse> getJugadoresByEquipoId(Long equipoId) {
        log.info(" Buscando jugadores para equipo ID: {}", equipoId);

        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + equipoId));

        List<Jugador> jugadores = jugadorRepository.findByEquipoId(equipoId);

        if (jugadores == null || jugadores.isEmpty()) {
            log.warn(" El equipo '{}' no tiene jugadores asignados", equipo.getNombre());
            return List.of();
        }

        log.info(" Se encontraron {} jugadores en el equipo '{}'", jugadores.size(), equipo.getNombre());

        return jugadores.stream()
                .map(JugadorResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EquipoResponse> listarTodosEquipos() {
        log.info(" Listando todos los equipos");
        return equipoRepository.findAll().stream()
                .map(EquipoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EquipoResponse> listarEquiposSinEntrenador() {
        log.info(" Listando equipos sin entrenador");
        return equipoRepository.findEquiposSinEntrenador().stream()
                .map(EquipoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EquipoResponse> listarEquiposConSolicitudPendiente() {
        log.info(" Listando equipos con solicitudes pendientes");
        return equipoRepository.findEquiposConSolicitudPendiente().stream()
                .map(EquipoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public EquipoResponse obtenerEquipoPorId(Long id) {
        log.info(" Obteniendo equipo por ID: {}", id);
        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + id));
        return EquipoResponse.fromEntity(equipo);
    }

    @Transactional(readOnly = true)
    public EquipoResponse obtenerEquipoPorCodigo(String codigo) {
        log.info(" Obteniendo equipo por código: {}", codigo);
        Equipo equipo = equipoRepository.findByCodigoSolicitud(codigo)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Código de equipo inválido: " + codigo));
        return EquipoResponse.fromEntity(equipo);
    }

    @Transactional
    public EquipoResponse actualizarEquipo(Long id, EquipoRequest dto) {
        log.info(" Actualizando equipo con ID: {}", id);

        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + id));

        if (dto.getNombre() != null && !dto.getNombre().equals(equipo.getNombre())) {
            if (equipoRepository.findByNombre(dto.getNombre()).isPresent()) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Ya existe un equipo con el nombre: " + dto.getNombre());
            }
            equipo.setNombre(dto.getNombre());
            log.info("   Nombre actualizado a: {}", dto.getNombre());
        }

        if (dto.getCiudad() != null) {
            equipo.setCiudad(dto.getCiudad());
            log.info("   Ciudad actualizada a: {}", dto.getCiudad());
        }

        if (dto.getNombreEstadio() != null) {
            equipo.setNombreEstadio(dto.getNombreEstadio());
            log.info("   Estadio actualizado a: {}", dto.getNombreEstadio());
        }

        if (dto.getAnoFundacion() != null) {
            equipo.setAnoFundacion(dto.getAnoFundacion());
            log.info("   Año fundación actualizado a: {}", dto.getAnoFundacion());
        }

        if (dto.getEscudoUrl() != null) {
            equipo.setEscudoUrl(dto.getEscudoUrl());
            log.info("   Escudo actualizado");
        }

        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada con ID: " + dto.getLigaId()));
            equipo.setLiga(liga);
            log.info("   Liga actualizada a: {} (ID: {})", liga.getNombreLiga(), liga.getId());
        } else {
            log.warn("   No se recibió ligaId, la liga se mantiene como: {}",
                    equipo.getLiga() != null ? equipo.getLiga().getNombreLiga() : "null");
        }

        Equipo saved = equipoRepository.save(equipo);
        log.info(" Equipo actualizado: {}", saved.getNombre());
        log.info("   Liga final: {}", saved.getLiga() != null ? saved.getLiga().getNombreLiga() : "ninguna");

        return EquipoResponse.fromEntity(saved);
    }

    @Transactional
    public void eliminarEquipo(Long id) {
        log.info(" Eliminando equipo con ID: {}", id);

        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + id));

        if (equipo.getEntrenador() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "No se puede eliminar el equipo porque tiene un entrenador asignado: " +
                            equipo.getEntrenador().getNombre());
        }

        long jugadoresCount = jugadorRepository.countByEquipoId(id);
        if (jugadoresCount > 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "No se puede eliminar el equipo porque tiene " + jugadoresCount + " jugadores asignados");
        }

        equipoRepository.deleteById(id);
        log.info(" Equipo eliminado: {}", id);
    }

    @Transactional
    public EquipoResponse regenerarCodigoSolicitud(Long equipoId) {
        log.info(" Regenerando código de solicitud para equipo ID: {}", equipoId);

        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + equipoId));

        String nuevoCodigo = generarCodigoSolicitud();
        equipo.setCodigoSolicitud(nuevoCodigo);
        equipo.setSolicitudPendiente(false);
        equipo.setEntrenadorSolicitanteId(null);

        Equipo saved = equipoRepository.save(equipo);
        log.info(" Nuevo código generado para equipo {}: {}", equipo.getNombre(), nuevoCodigo);

        return EquipoResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getEstadisticasEquipo(Long equipoId) {
        log.info(" Obteniendo estadísticas del equipo: {}", equipoId);

        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + equipoId));

        List<Partido> partidos = partidoRepository.findByEquipoLocalIdOrEquipoVisitanteId(equipoId);
        List<Jugador> jugadores = jugadorRepository.findByEquipoId(equipoId);

        Map<String, Object> estadisticas = new HashMap<>();
        estadisticas.put("equipoId", equipoId);
        estadisticas.put("nombreEquipo", equipo.getNombre());
        estadisticas.put("liga", equipo.getLiga() != null ? equipo.getLiga().getNombreLiga() : "Sin liga");
        estadisticas.put("totalPartidos", partidos.size());
        estadisticas.put("partidosGanados", equipo.getVictorias());
        estadisticas.put("partidosPerdidos", equipo.getDerrotas());
        estadisticas.put("puntosFavor", equipo.getPuntosFavor());
        estadisticas.put("puntosContra", equipo.getPuntosContra());
        estadisticas.put("diferenciaPuntos", equipo.getPuntosFavor() - equipo.getPuntosContra());
        estadisticas.put("numeroJugadores", jugadores.size());
        estadisticas.put("entrenador", equipo.getEntrenador() != null ?
                equipo.getEntrenador().getNombre() + " " + equipo.getEntrenador().getApellido() : "Sin entrenador");
        estadisticas.put("ciudad", equipo.getCiudad());
        estadisticas.put("estadio", equipo.getNombreEstadio());

        return estadisticas;
    }

    @Transactional(readOnly = true)
    public List<PartidoResponse> getProximosPartidosEquipo(Long equipoId) {
        log.info(" Obteniendo próximos partidos del equipo: {}", equipoId);

        return partidoRepository.findProximosPartidosByEquipo(equipoId, LocalDateTime.now()).stream()
                .limit(5)
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getPlantillaConEstadisticas(Long equipoId) {
        log.info(" Obteniendo plantilla con estadísticas del equipo: {}", equipoId);

        List<Jugador> jugadores = jugadorRepository.findByEquipoId(equipoId);

        return jugadores.stream().map(jugador -> {
            Map<String, Object> info = new HashMap<>();
            info.put("id", jugador.getId());
            info.put("nombre", jugador.getNombre() + " " + jugador.getApellido());
            info.put("dorsal", jugador.getDorsal());
            info.put("posicion", jugador.getPosicion());
            info.put("altura", jugador.getAltura());
            info.put("peso", jugador.getPeso());
            info.put("edad", jugador.getEdad());
            info.put("partidosJugados", jugador.getPartidosJugados());
            info.put("puntosTotales", jugador.getPuntosTotales());
            info.put("rebotesTotales", jugador.getRebotesTotales());
            info.put("asistenciasTotales", jugador.getAsistenciasTotales());

            double promedioPuntos = jugador.getPartidosJugados() > 0 ?
                    jugador.getPuntosTotales() / (double) jugador.getPartidosJugados() : 0;
            info.put("promedioPuntos", Math.round(promedioPuntos * 10) / 10.0);

            return info;
        }).collect(Collectors.toList());
    }
}
