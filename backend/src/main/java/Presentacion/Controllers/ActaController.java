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
import org.springframework.http.MediaType;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import jakarta.validation.Valid;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/actas")
@RequiredArgsConstructor
public class ActaController {

    private final ActaService actaService;
    private final AlineacionService alineacionService;

    @PostMapping("/guardar")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<?> guardarActa(@Valid @RequestBody ActaRequestDTO actaRequest) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        log.info(" Guardando acta para partido ID: {}", actaRequest.getPartidoId());

        boolean alineacionesListas = alineacionService.ambasAlineacionesConfirmadas(actaRequest.getPartidoId());
        if (!alineacionesListas) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("message", "No se puede crear el acta hasta que los entrenadores hayan confirmado las alineaciones de ambos equipos."));
        }

        return ResponseEntity.ok(actaService.guardarActa(actaRequest, username));
    }

    @GetMapping("/listar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ActaResponseDTO>> listarTodasActas() {
        return ResponseEntity.ok(actaService.listarTodas());
    }

    @GetMapping("/partido/{partidoId}/jugador/{jugadorId}/estadisticas")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getEstadisticasJugadorEnPartido(
            @PathVariable Long partidoId, @PathVariable Long jugadorId) {
        return ResponseEntity.ok(actaService.getEstadisticasJugadorEnPartido(partidoId, jugadorId));
    }

    @GetMapping("/partido/{partidoId}/equipo/{equipoId}/estadisticas")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getEstadisticasEquipoEnPartido(
            @PathVariable Long partidoId, @PathVariable Long equipoId) {
        return ResponseEntity.ok(actaService.getEstadisticasEquipoEnPartido(partidoId, equipoId));
    }

    @GetMapping("/partido/{partidoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ActaResponseDTO> obtenerActaPorPartido(@PathVariable Long partidoId,
                                                                 @AuthenticationPrincipal UserDetails userDetails) {
        ActaResponseDTO acta = actaService.obtenerActaPorPartido(partidoId, userDetails.getUsername());
        if (acta == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(acta);
    }

    @GetMapping("/{actaId}")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN', 'ENTRENADOR', 'JUGADOR')")
    public ResponseEntity<ActaResponseDTO> obtenerPorId(
            @PathVariable Long actaId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info(" Obteniendo acta por ID: {}", actaId);
        return ResponseEntity.ok(actaService.obtenerPorId(actaId, userDetails.getUsername()));
    }

    @PutMapping("/{actaId}")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<ActaResponseDTO> actualizarActa(
            @PathVariable Long actaId,
            @RequestBody ActaRequestDTO request,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info(" Actualizando acta ID: {}", actaId);
        return ResponseEntity.ok(actaService.actualizarActa(actaId, request, userDetails.getUsername()));
    }

    @DeleteMapping("/{actaId}")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<Void> eliminarActa(
            @PathVariable Long actaId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info(" Eliminando acta ID: {}", actaId);
        actaService.eliminarActa(actaId, userDetails.getUsername());
        return ResponseEntity.noContent().build();
    }

    @PostMapping(value = "/partido/{partidoId}/subir", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<?> subirArchivoActa(
            @PathVariable Long partidoId,
            @RequestParam("archivo") MultipartFile archivo,
            @RequestParam(value = "resultadoLocal", required = false) String resultadoLocal,
            @RequestParam(value = "resultadoVisitante", required = false) String resultadoVisitante,
            @RequestParam(value = "observaciones", required = false) String observaciones,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info(" Subiendo archivo de acta para partido ID: {}", partidoId);
        return ResponseEntity.ok(actaService.subirArchivoActa(
                partidoId, archivo, resultadoLocal, resultadoVisitante, observaciones, userDetails.getUsername()));
    }

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

    @GetMapping("/arbitro/{arbitroId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<List<ActaResponseDTO>> listarPorArbitro(
            @PathVariable Long arbitroId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info(" Listando actas del árbitro ID: {}", arbitroId);
        return ResponseEntity.ok(actaService.listarPorArbitro(arbitroId, userDetails.getUsername()));
    }

    @GetMapping("/equipo/{equipoId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ENTRENADOR', 'JUGADOR')")
    public ResponseEntity<List<ActaResponseDTO>> listarPorEquipo(
            @PathVariable Long equipoId,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info(" Listando actas del equipo ID: {}", equipoId);
        return ResponseEntity.ok(actaService.listarPorEquipo(equipoId, userDetails.getUsername()));
    }

    @GetMapping("/{actaId}/estadisticas")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN', 'ENTRENADOR', 'JUGADOR')")
    public ResponseEntity<Map<String, Object>> obtenerEstadisticasActa(@PathVariable Long actaId) {
        log.info(" Obteniendo estadísticas del acta ID: {}", actaId);
        return ResponseEntity.ok(actaService.obtenerEstadisticasActa(actaId));
    }

    @GetMapping("/{actaId}/pdf")
    public ResponseEntity<byte[]> descargarPdf(@PathVariable Long actaId) {
        log.info(" Descargando PDF del acta ID: {}", actaId);
        return actaService.generarPdf(actaId);
    }

    @GetMapping("/partido/{partidoId}/pdf")
    public ResponseEntity<byte[]> descargarPdfPorPartido(@PathVariable Long partidoId) {
        log.info(" Descargando PDF del acta para partido ID: {}", partidoId);
        return actaService.generarPdfPorPartido(partidoId);
    }

    @PostMapping("/{actaId}/compartir")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<Void> compartirActa(
            @PathVariable Long actaId,
            @RequestParam String email,
            @AuthenticationPrincipal UserDetails userDetails) {
        log.info(" Compartiendo acta ID: {} con email: {}", actaId, email);
        actaService.compartirActa(actaId, email, userDetails.getUsername());
        return ResponseEntity.ok().build();
    }
}
