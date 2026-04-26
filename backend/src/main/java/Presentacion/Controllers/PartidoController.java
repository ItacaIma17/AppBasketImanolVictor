package Presentacion.Controllers;

import Aplicacion.Services.PartidoService;
import Presentacion.DTOS.Partido.PartidoRequestDTO;
import Presentacion.DTOS.Partido.PartidoResponseDTO;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/partidos")
@RequiredArgsConstructor
public class    PartidoController {

    private final PartidoService partidoService;

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")  // ✅ Añadir esta anotación
    public ResponseEntity<PartidoResponseDTO> crearPartido(@RequestBody PartidoRequestDTO dto) {
        log.info("🏀 Creando nuevo partido: {} vs {}", dto.getEquipoLocalId(), dto.getEquipoVisitanteId());
        return ResponseEntity.status(HttpStatus.CREATED).body(partidoService.crearPartido(dto));
    }

    @GetMapping("/listar")
    @PreAuthorize("hasAnyRole('ADMIN', 'ENTRENADOR', 'ARBITRO', 'JUGADOR')")
    public ResponseEntity<List<PartidoResponseDTO>> listarPartidos() {
        log.info("📋 Listando todos los partidos");
        return ResponseEntity.ok(partidoService.listarTodosPartidos());
    }

    // Presentacion/Controllers/PartidoController.java

    @GetMapping("/entrenador/mis-partidos")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<List<PartidoResponseDTO>> getPartidosEntrenador(HttpServletRequest request) {

        // Obtener username del SecurityContextHolder
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
    public ResponseEntity<Void> eliminarPartido(@PathVariable Long partidoId) {
        log.info("🗑️ Eliminando partido: {}", partidoId);
        partidoService.eliminarPartido(partidoId);
        return ResponseEntity.noContent().build();
    }
}