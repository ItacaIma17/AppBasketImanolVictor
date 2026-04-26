// Presentacion/Controllers/EquipoController.java

package Presentacion.Controllers;

import Aplicacion.Services.EquipoService;
import Presentacion.DTOS.Equipo.EquipoRequest;
import Presentacion.DTOS.Equipo.EquipoResponse;
import Presentacion.DTOS.Equipo.SolicitarEquipoDTO;
import Presentacion.DTOS.Equipo.AprobarSolicitudDTO;
import Presentacion.DTOS.Jugador.JugadorResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/equipos")
@RequiredArgsConstructor
public class EquipoController {

    private final EquipoService equipoService;

    // ============================================================
    // CREAR EQUIPO
    // ============================================================

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoResponse> crearEquipo(@Valid @RequestBody EquipoRequest dto) {
        log.info("🏀 Creando equipo: {}", dto.getNombre());
        return ResponseEntity.status(HttpStatus.CREATED).body(equipoService.crearEquipo(dto));
    }

    // ============================================================
    // SOLICITUDES DE ENTRENADOR
    // ============================================================

    @PostMapping("/solicitar")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<Void> solicitarDirigirEquipo(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody SolicitarEquipoDTO dto) {
        log.info("📨 Entrenador {} solicita equipo con código: {}", userDetails.getUsername(), dto.getCodigoSolicitud());
        equipoService.solicitarDirigirEquipo(userDetails.getUsername(), dto);
        return ResponseEntity.ok().build();
    }

    // ============================================================
    // APROBAR SOLICITUD (ADMIN)
    // ============================================================

    @PostMapping("/aprobar-solicitud")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoResponse> aprobarSolicitud(
            @AuthenticationPrincipal UserDetails admin,
            @RequestBody AprobarSolicitudDTO dto) {
        log.info("✅ Admin {} aprobando/rechazando solicitud", admin.getUsername());
        return ResponseEntity.ok(equipoService.aprobarSolicitud(dto, admin.getUsername()));
    }

    // ============================================================
    // LISTAR EQUIPOS
    // ============================================================

    @GetMapping("/listar")
    public ResponseEntity<List<EquipoResponse>> listarEquipos() {
        log.info("📋 Listando todos los equipos");
        return ResponseEntity.ok(equipoService.listarTodosEquipos());
    }

    @GetMapping("/sin-entrenador")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EquipoResponse>> listarEquiposSinEntrenador() {
        log.info("📋 Listando equipos sin entrenador");
        return ResponseEntity.ok(equipoService.listarEquiposSinEntrenador());
    }

    @GetMapping("/solicitudes-pendientes")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EquipoResponse>> listarSolicitudesPendientes() {
        log.info("📋 Listando equipos con solicitudes pendientes");
        return ResponseEntity.ok(equipoService.listarEquiposConSolicitudPendiente());
    }

    // ============================================================
    // OBTENER EQUIPO (SÓLO UNO)
    // ============================================================

    @GetMapping("/{id}")
    public ResponseEntity<EquipoResponse> obtenerEquipo(@PathVariable Long id) {
        log.info("🔍 Obteniendo equipo con ID: {}", id);
        return ResponseEntity.ok(equipoService.obtenerEquipoPorId(id));
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<EquipoResponse> obtenerEquipoPorCodigo(@PathVariable String codigo) {
        log.info("🔍 Obteniendo equipo con código: {}", codigo);
        return ResponseEntity.ok(equipoService.obtenerEquipoPorCodigo(codigo));
    }

    // ============================================================
    // JUGADORES DEL EQUIPO
    // ============================================================

    // Presentacion/Controllers/EquipoController.java

    @GetMapping("/{equipoId}/jugadores")
    @PreAuthorize("hasAnyRole('ADMIN', 'ENTRENADOR', 'ARBITRO')")
    public ResponseEntity<List<JugadorResponse>> getJugadoresByEquipo(@PathVariable Long equipoId) {
        log.info("📋 Obteniendo jugadores del equipo: {}", equipoId);
        List<JugadorResponse> jugadores = equipoService.getJugadoresByEquipoId(equipoId);
        return ResponseEntity.ok(jugadores);
    }

    // ============================================================
    // ACTUALIZAR EQUIPO
    // ============================================================

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoResponse> actualizarEquipo(
            @PathVariable Long id,
            @Valid @RequestBody EquipoRequest dto) {
        log.info("✏️ Actualizando equipo ID: {}", id);
        return ResponseEntity.ok(equipoService.actualizarEquipo(id, dto));
    }

    // ============================================================
    // ELIMINAR EQUIPO
    // ============================================================

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> eliminarEquipo(@PathVariable Long id) {
        log.info("🗑️ Eliminando equipo ID: {}", id);
        equipoService.eliminarEquipo(id);
        return ResponseEntity.noContent().build();
    }

    // ============================================================
    // REGENERAR CÓDIGO
    // ============================================================

    @PostMapping("/{equipoId}/regenerar-codigo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoResponse> regenerarCodigoSolicitud(@PathVariable Long equipoId) {
        log.info("🔄 Regenerando código para equipo ID: {}", equipoId);
        return ResponseEntity.ok(equipoService.regenerarCodigoSolicitud(equipoId));
    }
}