package Presentacion.Controllers;

import Aplicacion.Services.ActaService;
import Aplicacion.Services.AlineacionService;
import Presentacion.DTOS.Arbitro.ActaRequestDTO;
import Presentacion.DTOS.Arbitro.ActaResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/actas")
@RequiredArgsConstructor
public class ActaController {

    private final ActaService actaService;
    private final AlineacionService alineacionService;

    // ============================================================
    // CRUD BÁSICO
    // ============================================================

    // ActaController.java — reemplaza la firma del método guardarActa
    @PostMapping("/guardar")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<?> guardarActa(@RequestBody ActaRequestDTO actaRequest) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        log.info("📝 Guardando acta para partido ID: {}", actaRequest.getPartidoId());

        // ✅ Verificar que ambas alineaciones estén confirmadas por el árbitro
        boolean alineacionesListas = alineacionService.ambasAlineacionesConfirmadas(actaRequest.getPartidoId());
        if (!alineacionesListas) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("message", "No se puede crear el acta hasta que el árbitro haya confirmado las alineaciones de ambos equipos."));
        }

        return ResponseEntity.ok(actaService.guardarActa(actaRequest, username));
    }

    @GetMapping("/partido/{partidoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ActaResponseDTO> obtenerActaPorPartido(@PathVariable Long partidoId,
                                                                 @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(actaService.obtenerActaPorPartido(partidoId, userDetails.getUsername()));
    }


    @GetMapping("/{actaId}")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN', 'ENTRENADOR', 'JUGADOR')")
    public ResponseEntity<ActaResponseDTO> obtenerPorId(
            @PathVariable Long actaId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info("🔍 Obteniendo acta por ID: {}", actaId);
        return ResponseEntity.ok(actaService.obtenerPorId(actaId, userDetails.getUsername()));
    }

    @PutMapping("/{actaId}")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<ActaResponseDTO> actualizarActa(
            @PathVariable Long actaId,
            @RequestBody ActaRequestDTO request,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info("✏️ Actualizando acta ID: {}", actaId);
        return ResponseEntity.ok(actaService.actualizarActa(actaId, request, userDetails.getUsername()));
    }

    @DeleteMapping("/{actaId}")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<Void> eliminarActa(
            @PathVariable Long actaId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info("🗑️ Eliminando acta ID: {}", actaId);
        actaService.eliminarActa(actaId, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }

    // ============================================================
    // VALIDACIONES Y EXISTENCIA
    // ============================================================

    @GetMapping("/partido/{partidoId}/existe")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN')")
    public ResponseEntity<Map<String, Boolean>> existeActa(@PathVariable Long partidoId) {
        return ResponseEntity.ok(Map.of("existe", actaService.existeActaPorPartido(partidoId)));
    }

    @GetMapping("/{actaId}/puede-editar")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN')")
    public ResponseEntity<Map<String, Boolean>> puedeEditar(
            @PathVariable Long actaId,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(Map.of(
                "puedeEditar", actaService.puedeEditar(actaId, userDetails.getUsername())));
    }

    // ============================================================
    // NUEVOS ENDPOINTS (LO QUE TE FALTABA)
    // ============================================================

    @GetMapping("/arbitro/{arbitroId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<List<ActaResponseDTO>> listarPorArbitro(
            @PathVariable Long arbitroId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info("📋 Listando actas del árbitro ID: {}", arbitroId);
        return ResponseEntity.ok(actaService.listarPorArbitro(arbitroId, userDetails.getUsername()));
    }

    @GetMapping("/equipo/{equipoId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ENTRENADOR', 'JUGADOR')")
    public ResponseEntity<List<ActaResponseDTO>> listarPorEquipo(
            @PathVariable Long equipoId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info("📋 Listando actas del equipo ID: {}", equipoId);
        return ResponseEntity.ok(actaService.listarPorEquipo(equipoId, userDetails.getUsername()));
    }

    @GetMapping("/{actaId}/estadisticas")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN', 'ENTRENADOR', 'JUGADOR')")
    public ResponseEntity<Map<String, Object>> obtenerEstadisticasActa(@PathVariable Long actaId) {
        log.info("📊 Obteniendo estadísticas del acta ID: {}", actaId);
        return ResponseEntity.ok(actaService.obtenerEstadisticasActa(actaId));
    }

    @GetMapping("/{actaId}/pdf")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN', 'ENTRENADOR', 'JUGADOR')")
    public ResponseEntity<byte[]> descargarPdf(@PathVariable Long actaId) {
        log.info("📄 Descargando PDF del acta ID: {}", actaId);
        return actaService.generarPdf(actaId);
    }

    @PostMapping("/{actaId}/compartir")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<Void> compartirActa(
            @PathVariable Long actaId,
            @RequestParam String email,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info("📧 Compartiendo acta ID: {} con email: {}", actaId, email);
        actaService.compartirActa(actaId, email, userDetails.getUsername());
        return ResponseEntity.ok().build();
    }
}