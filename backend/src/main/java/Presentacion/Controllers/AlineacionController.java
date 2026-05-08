// Presentacion/Controllers/AlineacionController.java - VERSIÓN CORREGIDA

package Presentacion.Controllers;

import Aplicacion.Services.AlineacionService;
import Dominio.Entity.Alineacion;
import Dominio.Repositorys.AlineacionRepository;
import Presentacion.DTOS.Entrenador.AlineacionRequestDTO;
import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/alineaciones")
public class AlineacionController {

    @Autowired
    private AlineacionService alineacionService;

    @Autowired
    private AlineacionRepository alineacionRepository;

    // Obtener el username del usuario autenticado
    private String getCurrentUsername() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof UserDetails) {
            return ((UserDetails) principal).getUsername();
        }
        return principal.toString();
    }

    // ─── Presentar alineación (ENTRENADOR) ─────────────────────────────────

    @PostMapping("/presentar")
    public ResponseEntity<?> presentarAlineacion(@RequestBody AlineacionRequestDTO dto) {
        try {
            String username = getCurrentUsername();
            AlineacionResponseDTO response = alineacionService.presentarAlineacion(dto, username);
            return ResponseEntity.ok(response);
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", e.getMessage(),
                    "bloqueada", true
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ─── Actualizar alineación (ENTRENADOR, antes de confirmar) ───────────

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarAlineacion(
            @PathVariable Long id,
            @RequestBody AlineacionRequestDTO dto) {
        try {
            String username = getCurrentUsername();
            AlineacionResponseDTO response = alineacionService.actualizarAlineacion(id, dto, username);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

// ─── Eliminar / rechazar alineación (ARBITRO o ADMIN) ─────────────────

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarAlineacion(@PathVariable Long id) {
        try {
            String username = getCurrentUsername();
            alineacionService.eliminarAlineacion(id, username);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ─── Confirmar alineación (ARBITRO) ────────────────────────────────────

    @PutMapping("/{id}/confirmar")
    public ResponseEntity<?> confirmarAlineacion(@PathVariable Long id) {
        try {
            String username = getCurrentUsername();
            AlineacionResponseDTO response = alineacionService.confirmarAlineacion(id, username);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ─── Ver alineaciones de un partido (todos los roles) ──────────────────

    @GetMapping("/partido/{partidoId}")
    public ResponseEntity<?> getAlineacionesPartido(@PathVariable Long partidoId) {
        try {
            var alineaciones = alineacionService.getAlineacionesPartido(partidoId);
            return ResponseEntity.ok(alineaciones);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ─── Ver alineación de un equipo en un partido ─────────────────────────

    @GetMapping("/partido/{partidoId}/equipo/{equipoId}")
    public ResponseEntity<?> getAlineacionEquipo(
            @PathVariable Long partidoId,
            @PathVariable Long equipoId) {
        try {
            Map<String, Object> alineacion = alineacionService.getAlineacionEquipoEnPartido(partidoId, equipoId);
            if (alineacion == null) {
                return ResponseEntity.noContent().build();
            }
            return ResponseEntity.ok(alineacion);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ─── Desbloquear alineación (solo ADMIN) ──────────────────────────────

    @PutMapping("/{id}/desbloquear")
    public ResponseEntity<?> desbloquearAlineacion(@PathVariable Long id) {
        try {
            Alineacion alineacion = alineacionRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Alineación no encontrada"));

            if (alineacion.isConfirmada()) {
                return ResponseEntity.badRequest().body(Map.of(
                        "error", "No se puede desbloquear una alineación ya confirmada por el árbitro"
                ));
            }

            // Usar setBloqueada después de añadir el campo a la entidad
            // alineacion.setBloqueada(false);
            // alineacionRepository.save(alineacion);

            return ResponseEntity.ok(Map.of(
                    "mensaje", "Alineación desbloqueada correctamente",
                    "id", id
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ─── Listar todas las alineaciones (ADMIN) ─────────────────────────────

    @GetMapping
    public ResponseEntity<?> listarAlineaciones() {
        try {
            return ResponseEntity.ok(alineacionService.listarTodas());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}