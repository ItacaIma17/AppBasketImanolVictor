package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Repositorys.*;
import Presentacion.DTOS.Partido.PartidoRequestDTO;
import Presentacion.DTOS.Partido.PartidoResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDateTime;
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

    // ============================================================
    // CREAR PARTIDO
    // ============================================================

    @Transactional
    public PartidoResponseDTO crearPartido(PartidoRequestDTO dto) {
        log.info("========================================");
        log.info("🏀 Creando partido:");
        log.info("   Equipo Local ID: {}", dto.getEquipoLocalId());
        log.info("   Equipo Visitante ID: {}", dto.getEquipoVisitanteId());
        log.info("   Fecha: {}", dto.getFecha());
        log.info("   Ubicación: {}", dto.getUbicacion());
        log.info("   Liga ID: {}", dto.getLigaId());

        // Validar equipos
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

        // Validar que no sean el mismo equipo
        if (equipoLocal.getId().equals(equipoVisitante.getId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Un equipo no puede jugar contra sí mismo");
        }

        // Validar fecha
        if (dto.getFecha() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La fecha del partido es obligatoria");
        }

        if (dto.getFecha().isBefore(LocalDateTime.now())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La fecha del partido no puede ser en el pasado");
        }

        // Validar que no exista ya un partido entre estos equipos
        boolean existe = partidoRepository.existsPartidoEntreEquipos(
                equipoLocal.getId(), equipoVisitante.getId());
        if (existe) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un partido programado entre estos equipos");
        }

        // Crear partido
        Partido partido = new Partido();
        partido.setEquipoLocal(equipoLocal);
        partido.setEquipoVisitante(equipoVisitante);
        partido.setFecha(dto.getFecha());
        partido.setUbicacion(dto.getUbicacion());
        partido.setEstado("PROGRAMADO");

        // Asignar liga si se proporciona
        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada con ID: " + dto.getLigaId()));
            partido.setLiga(liga);
        }

        Partido saved = partidoRepository.save(partido);
        log.info("✅ Partido creado con ID: {}", saved.getId());
        log.info("========================================");

        return PartidoResponseDTO.fromEntity(saved);
    }

    // ============================================================
    // LISTAR PARTIDOS
    // ============================================================

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> listarTodosPartidos() {
        log.info("📋 Listando todos los partidos");
        return partidoRepository.findAll().stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> listarPartidosPorEstado(String estado) {
        log.info("📋 Listando partidos con estado: {}", estado);
        return partidoRepository.findByEstado(estado).stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> listarPartidosPendientes() {
        log.info("📋 Listando partidos pendientes");
        return partidoRepository.findPartidosPendientes().stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> listarPartidosFuturos() {
        log.info("📋 Listando partidos futuros");
        return partidoRepository.findPartidosFuturos(LocalDateTime.now()).stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // ============================================================
    // PARTIDOS POR EQUIPO
    // ============================================================



    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> getPartidosByEquipoAndEstado(Long equipoId, String estado) {
        log.info("📋 Buscando partidos para equipo ID: {} con estado: {}", equipoId, estado);

        if (!equipoRepository.existsById(equipoId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Equipo no encontrado con ID: " + equipoId);
        }

        return partidoRepository.findByEquipoIdAndEstado(equipoId, estado).stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> getProximosPartidosByEquipo(Long equipoId) {
        log.info("📋 Buscando próximos partidos para equipo ID: {}", equipoId);

        if (!equipoRepository.existsById(equipoId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Equipo no encontrado con ID: " + equipoId);
        }

        return partidoRepository.findProximosPartidosByEquipo(equipoId, LocalDateTime.now()).stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // ============================================================
    // PARTIDOS POR ENTRENADOR
    // ============================================================

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> getPartidosByEntrenador(String username) {
        log.info("📋 Buscando partidos para entrenador: {}", username);

        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado: " + username));

        if (entrenador.getEquipo() == null) {
            log.warn("Entrenador {} no tiene equipo asignado", username);
            return List.of();
        }

        Long equipoId = entrenador.getEquipo().getId();
        log.info("Entrenador {} tiene equipo ID: {}", username, equipoId);

        return getPartidosByEquipo(equipoId);
    }

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> getProximosPartidosByEntrenador(String username) {
        log.info("📋 Buscando próximos partidos para entrenador: {}", username);

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

    // ============================================================
    // PARTIDOS POR ÁRBITRO
    // ============================================================


    public List<PartidoResponseDTO> getPartidosByArbitro(String username) {
        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Árbitro no encontrado"));

        List<Partido> partidos = partidoRepository.findByArbitroId(arbitro.getId());

        return partidos.stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    public PartidoResponseDTO getPartidoById(Long partidoId) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));
        return PartidoResponseDTO.fromEntity(partido);
    }

    // ============================================================
    // PARTIDOS POR LIGA
    // ============================================================

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> getPartidosByLiga(Long ligaId) {
        log.info("📋 Buscando partidos para liga ID: {}", ligaId);

        if (!ligaRepository.existsById(ligaId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Liga no encontrada con ID: " + ligaId);
        }

        return partidoRepository.findByLigaId(ligaId).stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // ============================================================
    // OBTENER UN PARTIDO
    // ============================================================

    @Transactional(readOnly = true)
    public PartidoResponseDTO obtenerPartidoPorId(Long id) {
        log.info("🔍 Buscando partido con ID: {}", id);

        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + id));

        return PartidoResponseDTO.fromEntity(partido);
    }

    // ============================================================
    // ACTUALIZAR PARTIDO
    // ============================================================

    @Transactional
    public PartidoResponseDTO actualizarPartido(Long id, PartidoRequestDTO dto) {
        log.info("✏️ Actualizando partido ID: {}", id);

        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + id));

        if (partido.getEstado().equals("FINALIZADO")) {
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
            if (dto.getFecha().isBefore(LocalDateTime.now())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "La fecha del partido no puede ser en el pasado");
            }
            partido.setFecha(dto.getFecha());
        }

        if (dto.getUbicacion() != null) {
            partido.setUbicacion(dto.getUbicacion());
        }

        if (dto.getLigaId() != null) {
            Liga liga = ligaRepository.findById(dto.getLigaId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Liga no encontrada"));
            partido.setLiga(liga);
        }

        Partido saved = partidoRepository.save(partido);
        log.info("✅ Partido actualizado: {}", saved.getId());

        return PartidoResponseDTO.fromEntity(saved);
    }

    @Transactional
    public PartidoResponseDTO actualizarResultado(Long partidoId, Map<String, Integer> resultado) {
        log.info("✏️ Actualizando resultado del partido ID: {}", partidoId);

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
        log.info("✅ Resultado actualizado: {} - {}", resultadoLocal, resultadoVisitante);

        return PartidoResponseDTO.fromEntity(saved);
    }

    @Transactional
    public PartidoResponseDTO asignarArbitro(Long partidoId, Long arbitroId) {
        log.info("👨‍⚖️ Asignando árbitro ID: {} al partido ID: {}", arbitroId, partidoId);

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
        log.info("✅ Árbitro {} asignado al partido {}", arbitro.getNombre(), saved.getId());

        return PartidoResponseDTO.fromEntity(saved);
    }

    // ============================================================
    // ELIMINAR PARTIDO
    // ============================================================

    @Transactional
    public void eliminarPartido(Long id) {
        log.info("🗑️ Eliminando partido ID: {}", id);

        Partido partido = partidoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + id));

        if (partido.getEstado().equals("FINALIZADO")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "No se puede eliminar un partido finalizado");
        }

        partidoRepository.deleteById(id);
        log.info("✅ Partido eliminado: {}", id);
    }

    // ============================================================
    // CAMBIAR ESTADO
    // ============================================================

    @Transactional
    public PartidoResponseDTO cambiarEstado(Long partidoId, String nuevoEstado) {
        log.info("🔄 Cambiando estado del partido ID: {} a {}", partidoId, nuevoEstado);

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
        log.info("✅ Estado del partido {} cambiado a {}", saved.getId(), nuevoEstado);

        return PartidoResponseDTO.fromEntity(saved);
    }

    // Aplicacion/Services/PartidoService.java

    @Transactional(readOnly = true)
    public List<PartidoResponseDTO> getPartidosByEquipo(Long equipoId) {
        log.info("📋 Buscando partidos para equipo ID: {}", equipoId);

        if (!equipoRepository.existsById(equipoId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Equipo no encontrado con ID: " + equipoId);
        }

        return partidoRepository.findByEquipoLocalIdOrEquipoVisitanteId(equipoId).stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }
}