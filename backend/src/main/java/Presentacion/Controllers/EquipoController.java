package Presentacion.Controllers;

import Aplicacion.Services.EquipoService;
import Presentacion.DTOS.Equipo.EquipoRequest;
import Presentacion.DTOS.Equipo.EquipoResponse;
import Presentacion.DTOS.Equipo.SolicitarEquipoDTO;
import Presentacion.DTOS.Equipo.AprobarSolicitudDTO;
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

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoResponse> crearEquipo(@Valid @RequestBody EquipoRequest dto) {
        log.info("🏀 Creando nuevo equipo: {}", dto.getNombre());
        return ResponseEntity.status(HttpStatus.CREATED).body(equipoService.crearEquipo(dto));
    }

    @PostMapping("/solicitar")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<Void> solicitarDirigirEquipo(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestBody SolicitarEquipoDTO dto) {

        // VALIDAR que userDetails no es null
        if (userDetails == null) {
            log.error("UserDetails es null - No hay usuario autenticado");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = userDetails.getUsername();
        log.info("📨 Entrenador {} solicita equipo con código: {}", username, dto.getCodigoSolicitud());

        // Verificar que el username no sea null o vacío
        if (username == null || username.isEmpty()) {
            log.error("Username es null o vacío");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        equipoService.solicitarDirigirEquipo(username, dto);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/aprobar-solicitud")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoResponse> aprobarSolicitud(
            @AuthenticationPrincipal UserDetails admin,
            @RequestBody AprobarSolicitudDTO dto) {
        log.info("✅ Admin {} aprobando/rechazando solicitud", admin.getUsername());
        return ResponseEntity.ok(equipoService.aprobarSolicitud(dto, admin.getUsername()));
    }

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
}