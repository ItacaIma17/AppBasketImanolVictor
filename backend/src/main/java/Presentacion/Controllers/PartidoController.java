package Presentacion.Controllers;

import Aplicacion.Services.PartidoService;
import Dominio.Entity.Arbitro;
import Dominio.Entity.Partido;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.ArbitroRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Arbitro.ArbitroResponse;
import Presentacion.DTOS.Partido.PartidoRequestDTO;
import Presentacion.DTOS.Partido.PartidoResponseDTO;
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
            log.info("🏀 Creando nuevo partido: local={}, visitante={}",
                    dto.getEquipoLocalId(), dto.getEquipoVisitanteId());

            PartidoResponseDTO partido = partidoService.crearPartido(dto);
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

    @GetMapping("/listar")
    @PreAuthorize("hasAnyRole('ADMIN', 'ENTRENADOR', 'ARBITRO', 'JUGADOR')")
    public ResponseEntity<List<PartidoResponseDTO>> listarPartidos() {
        log.info("📋 Listando todos los partidos");
        return ResponseEntity.ok(partidoService.listarTodosPartidos());
    }

    @GetMapping("/entrenador/mis-partidos")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<List<PartidoResponseDTO>> getPartidosEntrenador() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = authentication.getName();
        log.info("Listando partidos del entrenador: {}", username);

        List<PartidoResponseDTO> partidos = partidoService.getPartidosByEntrenador(username);
        return ResponseEntity.ok(partidos);
    }

    @GetMapping("/equipo/{equipoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<PartidoResponseDTO>> getPartidosByEquipo(@PathVariable Long equipoId) {
        log.info("📋 Listando partidos del equipo: {}", equipoId);
        return ResponseEntity.ok(partidoService.getPartidosByEquipo(equipoId));
    }

    @GetMapping("/{partidoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<PartidoResponseDTO> getPartidoById(@PathVariable Long partidoId) {
        log.info("📋 Obteniendo partido: {}", partidoId);
        PartidoResponseDTO partido = partidoService.getPartidoById(partidoId);
        return ResponseEntity.ok(partido);
    }

    @PutMapping("/{partidoId}/resultado")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<PartidoResponseDTO> actualizarResultado(
            @PathVariable Long partidoId,
            @RequestBody Map<String, Integer> resultado) {
        log.info("✏️ Actualizando resultado del partido {}: {} - {}",
                partidoId, resultado.get("resultadoLocal"), resultado.get("resultadoVisitante"));
        return ResponseEntity.ok(partidoService.actualizarResultado(partidoId, resultado));
    }

    @DeleteMapping("/{partidoId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> eliminarPartido(@PathVariable Long partidoId) {
        try {
            log.info("🗑️ Eliminando partido: {}", partidoId);
            partidoService.eliminarPartido(partidoId);
            return ResponseEntity.ok(Map.of("message", "Partido eliminado correctamente"));

        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(Map.of("error", e.getReason()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    // ==================== ENDPOINTS PARA ÁRBITROS ====================

    @PutMapping("/{partidoId}/arbitro/{arbitroId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> asignarArbitro(
            @PathVariable Long partidoId,
            @PathVariable Long arbitroId) {

        try {
            Partido partido = partidoRepository.findById(partidoId)
                    .orElseThrow(() -> new RuntimeException("Partido no encontrado"));

            Arbitro arbitro = arbitroRepository.findById(arbitroId)
                    .orElseThrow(() -> new RuntimeException("Árbitro no encontrado"));

            partido.setArbitro(arbitro);
            partidoRepository.save(partido);

            log.info("✅ Árbitro {} asignado al partido {}", arbitroId, partidoId);
            return ResponseEntity.ok(Map.of("message", "Árbitro asignado correctamente"));

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
    public ResponseEntity<List<PartidoResponseDTO>> getMisPartidosArbitro() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = authentication.getName();
        log.info("Listando partidos del árbitro: {}", username);

        List<PartidoResponseDTO> partidos = partidoService.getPartidosByArbitro(username);
        return ResponseEntity.ok(partidos);
    }
}