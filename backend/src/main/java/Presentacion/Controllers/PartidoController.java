package Presentacion.Controllers;

import Aplicacion.Services.PartidoService;
import Dominio.Entity.Arbitro;
import Dominio.Entity.Partido;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.ArbitroRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Arbitro.ArbitroResponse;
import Presentacion.DTOS.Partido.CrearPartidoCompletoDTO;
import Presentacion.DTOS.Partido.PartidoRequestDTO;
import Presentacion.DTOS.Partido.PartidoResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/partidos")
@RequiredArgsConstructor
public class PartidoController {

    private final PartidoService partidoService;
    private final PartidoRepository partidoRepository;
    private final ArbitroRepository arbitroRepository;

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> crearPartido(@Valid @RequestBody PartidoRequestDTO dto) {
        try {
            log.info("Creando nuevo partido: local={}, visitante={}",
                    dto.getEquipoLocalId(), dto.getEquipoVisitanteId());

            PartidoResponse partido = partidoService.crearPartido(dto);
            return ResponseEntity.status(HttpStatus.CREATED).body(partido);

        } catch (ResponseStatusException e) {
            log.error("Error creando partido: {}", e.getReason());
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));
        } catch (Exception e) {
            log.error("Error inesperado creando partido: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error interno del servidor: " + e.getMessage()));
        }
    }

    @GetMapping("/liga/{ligaId}")
    public ResponseEntity<List<PartidoResponse>> listarPorLiga(@PathVariable Long ligaId) {
        return ResponseEntity.ok(partidoService.getPartidosByLiga(ligaId));
    }

    @GetMapping("/listar")
    @PreAuthorize("hasAnyRole('ADMIN', 'ENTRENADOR', 'ARBITRO', 'JUGADOR')")
    public ResponseEntity<List<PartidoResponse>> listarPartidos() {
        log.info(" Listando todos los partidos");
        return ResponseEntity.ok(partidoService.listarTodosPartidos());
    }

    @PostMapping("/crear-completo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<PartidoResponse>> crearPartidosCompleto(@RequestBody CrearPartidoCompletoDTO dto) {
        log.info(" Creando partidos con jornadas");
        return ResponseEntity.ok(partidoService.crearPartidosConJornadas(dto));
    }

    @GetMapping("/entrenador/mis-partidos")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<List<PartidoResponse>> getPartidosEntrenador() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = authentication.getName();
        log.info("Listando partidos del entrenador: {}", username);

        List<PartidoResponse> partidos = partidoService.getPartidosByEntrenador(username);
        return ResponseEntity.ok(partidos);
    }

    @GetMapping("/jugador/mis-partidos")
    @PreAuthorize("hasRole('JUGADOR')")
    public ResponseEntity<List<PartidoResponse>> getPartidosJugador() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = authentication.getName();
        log.info("Listando partidos del jugador: {}", username);

        List<PartidoResponse> partidos = partidoService.getPartidosByJugador(username);
        return ResponseEntity.ok(partidos);
    }

    @GetMapping("/jugador/proximos-partidos")
    @PreAuthorize("hasRole('JUGADOR')")
    public ResponseEntity<List<PartidoResponse>> getProximosPartidosJugador() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = authentication.getName();
        log.info("Listando próximos partidos del jugador: {}", username);

        List<PartidoResponse> partidos = partidoService.getProximosPartidosByJugador(username);
        return ResponseEntity.ok(partidos);
    }

    @GetMapping("/equipo/{equipoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<PartidoResponse>> getPartidosByEquipo(@PathVariable Long equipoId) {
        log.info(" Listando partidos del equipo: {}", equipoId);
        return ResponseEntity.ok(partidoService.getPartidosByEquipo(equipoId));
    }

    @GetMapping("/{partidoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<PartidoResponse> getPartidoById(@PathVariable Long partidoId) {
        log.info(" Obteniendo partido: {}", partidoId);
        PartidoResponse partido = partidoService.getPartidoById(partidoId);
        return ResponseEntity.ok(partido);
    }

    @PutMapping("/{partidoId}/resultado")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<PartidoResponse> actualizarResultado(
            @PathVariable Long partidoId,
            @RequestBody Map<String, Integer> resultado) {
        log.info(" Actualizando resultado del partido {}: {} - {}",
                partidoId, resultado.get("resultadoLocal"), resultado.get("resultadoVisitante"));
        return ResponseEntity.ok(partidoService.actualizarResultado(partidoId, resultado));
    }

    @PutMapping("/{partidoId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> actualizarPartido(
            @PathVariable Long partidoId,
            @RequestBody PartidoRequestDTO dto) {
        try {
            log.info(" PUT /partidos/{}  body={}", partidoId, dto);
            PartidoResponse actualizado = partidoService.actualizarPartido(partidoId, dto);
            return ResponseEntity.ok(actualizado);
        } catch (ResponseStatusException e) {
            log.error("Error actualizando partido {}: {}", partidoId, e.getReason());
            return ResponseEntity.status(e.getStatusCode())
                    .body(Map.of("error", e.getReason() != null ? e.getReason() : "Error"));
        } catch (Exception e) {
            log.error("Error inesperado actualizando partido {}: {}", partidoId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error interno: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{partidoId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> eliminarPartido(@PathVariable Long partidoId) {
        try {
            log.info(" Eliminando partido: {}", partidoId);
            partidoService.eliminarPartido(partidoId);
            return ResponseEntity.ok(Map.of("message", "Partido eliminado correctamente"));

        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{partidoId}/arbitro/{arbitroId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> asignarArbitro(
            @PathVariable Long partidoId,
            @PathVariable Long arbitroId) {

        try {
            Partido partido = partidoRepository.findById(partidoId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

            Arbitro arbitro = arbitroRepository.findById(arbitroId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Árbitro no encontrado"));

            partido.setArbitro(arbitro);
            partidoRepository.save(partido);

            log.info(" Árbitro {} asignado al partido {}", arbitroId, partidoId);
            return ResponseEntity.ok(Map.of("message", "Árbitro asignado correctamente"));

        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));
        } catch (Exception e) {
            log.error("Error asignando árbitro: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/arbitros/disponibles")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ArbitroResponse>> getArbitrosDisponibles() {
        List<Arbitro> arbitros = arbitroRepository.findAll();
        List<ArbitroResponse> response = arbitros.stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/arbitro/mis-partidos")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<List<PartidoResponse>> getMisPartidosArbitro() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = authentication.getName();
        log.info("Listando partidos del árbitro: {}", username);

        List<PartidoResponse> partidos = partidoService.getPartidosByArbitro(username);
        return ResponseEntity.ok(partidos);
    }

    @GetMapping("/{partidoId}/detalle-completo")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getDetalleCompletoPartido(@PathVariable Long partidoId) {
        log.info(" Obteniendo detalle completo del partido: {}", partidoId);
        return ResponseEntity.ok(partidoService.getDetalleCompletoPartido(partidoId));
    }

    @PostMapping("/{partidoId}/finalizar")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<PartidoResponse> finalizarPartido(
            @PathVariable Long partidoId,
            @RequestBody Map<String, Integer> resultado) {
        log.info(" Finalizando partido {}: {} - {}", partidoId,
                resultado.get("resultadoLocal"), resultado.get("resultadoVisitante"));
        return ResponseEntity.ok(partidoService.finalizarPartido(
                partidoId,
                resultado.get("resultadoLocal"),
                resultado.get("resultadoVisitante")));
    }

    @GetMapping("/equipo/{equipoId}/historial")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getHistorialEquipo(@PathVariable Long equipoId) {
        log.info(" Obteniendo historial del equipo: {}", equipoId);
        return ResponseEntity.ok(partidoService.getHistorialEquipo(equipoId));
    }

    @GetMapping("/equipo/{equipoId}/proximos")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<PartidoResponse>> getProximosPartidosByEquipo(@PathVariable Long equipoId) {
        log.info(" Obteniendo próximos partidos del equipo: {}", equipoId);
        return ResponseEntity.ok(partidoService.getProximosPartidosByEquipo(equipoId));
    }
}
