package Aplicacion.Services;

import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import Dominio.Entity.Entrenador;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.LigaRepository;
import Dominio.Repositorys.EntrenadorRepository;
import Presentacion.DTOS.Equipo.EquipoRequest;
import Presentacion.DTOS.Equipo.EquipoResponse;
import Presentacion.DTOS.Equipo.SolicitarEquipoDTO;
import Presentacion.DTOS.Equipo.AprobarSolicitudDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.security.SecureRandom;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EquipoService {

    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;
    private final EntrenadorRepository entrenadorRepository;

    private static final String CODIGO_PREFIX = "EQ-";
    private static final SecureRandom random = new SecureRandom();

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
        log.info("Creando equipo: {}", dto.getNombre());

        if (equipoRepository.findByNombre(dto.getNombre()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un equipo con ese nombre");
        }

        Liga liga = null;
        if (dto.getLigaId() != null) {
            liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada"));
        }

        Equipo equipo = dto.toEntity();
        equipo.setLiga(liga);

        // Generar código de solicitud
        equipo.setCodigoSolicitud(generarCodigoSolicitud());
        equipo.setSolicitudPendiente(false);

        Equipo saved = equipoRepository.save(equipo);
        log.info("Equipo creado con ID: {} y código: {}", saved.getId(), saved.getCodigoSolicitud());

        return EquipoResponse.fromEntity(saved);
    }

    // Aplicacion/Services/EquipoService.java

    @Transactional
    public void solicitarDirigirEquipo(String username, SolicitarEquipoDTO dto) {
        log.info("========================================");
        log.info("📨 Solicitud de equipo para entrenador: {}", username);
        log.info("   Código de solicitud: {}", dto.getCodigoSolicitud());

        // Validar parámetros
        if (username == null || username.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Username del entrenador no proporcionado");
        }

        if (dto.getCodigoSolicitud() == null || dto.getCodigoSolicitud().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Código de solicitud no proporcionado");
        }

        // Buscar el entrenador por username (NO por UserDetails)
        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> {
                    log.error("❌ Entrenador no encontrado con username: {}", username);
                    return new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Entrenador no encontrado con username: " + username);
                });

        log.info("✅ Entrenador encontrado:");
        log.info("   ID: {}", entrenador.getId());
        log.info("   Nombre: {} {}", entrenador.getNombre(), entrenador.getApellido());
        log.info("   Username: {}", entrenador.getUsername());

        // Verificar si ya tiene equipo
        if (entrenador.getEquipo() != null) {
            log.warn("⚠️ El entrenador ya tiene un equipo asignado: {}", entrenador.getEquipo().getNombre());
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya tienes un equipo asignado: " + entrenador.getEquipo().getNombre());
        }

        // Buscar el equipo por código de solicitud
        Equipo equipo = equipoRepository.findByCodigoSolicitud(dto.getCodigoSolicitud())
                .orElseThrow(() -> {
                    log.error("❌ Equipo no encontrado con código: {}", dto.getCodigoSolicitud());
                    return new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Código de equipo inválido: " + dto.getCodigoSolicitud());
                });

        log.info("✅ Equipo encontrado:");
        log.info("   ID: {}", equipo.getId());
        log.info("   Nombre: {}", equipo.getNombre());
        log.info("   Entrenador actual: {}", equipo.getEntrenador() != null ? equipo.getEntrenador().getNombre() : "ninguno");

        // Verificar si el equipo ya tiene entrenador
        if (equipo.getEntrenador() != null) {
            log.warn("⚠️ El equipo {} ya tiene un entrenador asignado: {}",
                    equipo.getNombre(), equipo.getEntrenador().getNombre());
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este equipo ya tiene un entrenador asignado");
        }

        // Verificar si ya hay solicitud pendiente
        if (equipo.getSolicitudPendiente() != null && equipo.getSolicitudPendiente()) {
            log.warn("⚠️ El equipo {} ya tiene una solicitud pendiente", equipo.getNombre());
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya hay una solicitud pendiente para este equipo");
        }

        // Crear la solicitud
        equipo.setSolicitudPendiente(true);
        equipo.setEntrenadorSolicitanteId(entrenador.getId());
        equipoRepository.save(equipo);

        log.info("✅ Solicitud registrada exitosamente:");
        log.info("   Entrenador: {} {}", entrenador.getNombre(), entrenador.getApellido());
        log.info("   Equipo: {}", equipo.getNombre());
        log.info("   Estado: PENDIENTE");
        log.info("========================================");
    }

    @Transactional
    public EquipoResponse aprobarSolicitud(AprobarSolicitudDTO dto, String adminUsername) {
        log.info("Admin {} procesando solicitud para equipo código: {}",
                adminUsername, dto.getCodigoSolicitud());

        Equipo equipo = equipoRepository.findByCodigoSolicitud(dto.getCodigoSolicitud())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Código de equipo inválido"));

        if (!Boolean.TRUE.equals(equipo.getSolicitudPendiente())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "No hay solicitud pendiente para este equipo");
        }

        Entrenador entrenador = entrenadorRepository.findById(dto.getEntrenadorId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado"));

        if (dto.getAprobar()) {
            // Asignar equipo al entrenador
            entrenador.setEquipo(equipo);
            equipo.setEntrenador(entrenador);
            equipo.setSolicitudPendiente(false);
            equipo.setEntrenadorSolicitanteId(null);

            entrenadorRepository.save(entrenador);
            equipoRepository.save(equipo);

            log.info("✅ Solicitud APROBADA: Entrenador {} asignado a equipo {}",
                    entrenador.getUsername(), equipo.getNombre());
        } else {
            // Rechazar solicitud
            equipo.setSolicitudPendiente(false);
            equipo.setEntrenadorSolicitanteId(null);
            equipoRepository.save(equipo);

            log.info("❌ Solicitud RECHAZADA para entrenador {} en equipo {}",
                    entrenador.getUsername(), equipo.getNombre());
        }

        return EquipoResponse.fromEntity(equipo);
    }

    @Transactional(readOnly = true)
    public List<EquipoResponse> listarTodosEquipos() {
        return equipoRepository.findAll().stream()
                .map(EquipoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EquipoResponse> listarEquiposSinEntrenador() {
        return equipoRepository.findEquiposSinEntrenador().stream()
                .map(EquipoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<EquipoResponse> listarEquiposConSolicitudPendiente() {
        return equipoRepository.findEquiposConSolicitudPendiente().stream()
                .map(EquipoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public EquipoResponse obtenerEquipoPorId(Long id) {
        Equipo equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado"));
        return EquipoResponse.fromEntity(equipo);
    }

    @Transactional(readOnly = true)
    public EquipoResponse obtenerEquipoPorCodigo(String codigo) {
        Equipo equipo = equipoRepository.findByCodigoSolicitud(codigo)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Código de equipo inválido"));
        return EquipoResponse.fromEntity(equipo);
    }
}