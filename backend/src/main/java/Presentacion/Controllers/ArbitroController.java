package Presentacion.Controllers;

import Aplicacion.Services.ArbitroService;
import Presentacion.DTOS.Alineacion.AlineacionesParaPartidoDTO;
import Presentacion.DTOS.Alineacion.AlineacionesPartidoDTO;
import Presentacion.DTOS.Arbitro.ArbitroEstadisticasResponse;
import Presentacion.DTOS.Arbitro.ArbitroRequest;
import Presentacion.DTOS.Arbitro.ArbitroResponse;
import Presentacion.DTOS.Arbitro.AsignarArbitroDTO;
import Presentacion.DTOS.Partido.PartidoResponse;
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
@RequestMapping("/api/arbitros")
@RequiredArgsConstructor
public class ArbitroController {

    private final ArbitroService arbitroService;

    @GetMapping("/mis-partidos")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<List<PartidoResponse>> getMisPartidos() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }
        String username = authentication.getName();
        log.info(" Obteniendo partidos del árbitro: {}", username);
        return ResponseEntity.ok(arbitroService.getPartidosAsignados(username));
    }

    @PostMapping("/partido/{partidoId}/confirmar-alineaciones")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<?> confirmarAlineaciones(@PathVariable Long partidoId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth.getName();
        log.info(" Árbitro {} confirmando alineaciones del partido {}", username, partidoId);

        boolean ok = arbitroService.confirmarAlineaciones(partidoId, username);
        if (!ok) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(Map.of("message", "Faltan alineaciones por subir. Ambos entrenadores deben haberlas enviado antes."));
        }
        return ResponseEntity.ok(Map.of("message", "Alineaciones confirmadas. Ya puedes crear el acta."));
    }

    @GetMapping("/partido/{partidoId}/alineaciones")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<AlineacionesPartidoDTO> getAlineacionesPartido(@PathVariable Long partidoId) {
        log.info(" Obteniendo alineaciones para acta del partido: {}", partidoId);
        return ResponseEntity.ok(arbitroService.getAlineacionesPartido(partidoId));
    }

    @GetMapping("/listar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ArbitroResponse>> listarArbitros() {
        log.info(" Listando todos los árbitros");
        return ResponseEntity.ok(arbitroService.listarTodosArbitros());
    }

    @GetMapping("/disponibles")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ArbitroResponse>> listarArbitrosDisponibles() {
        log.info(" Listando árbitros disponibles");
        return ResponseEntity.ok(arbitroService.listarArbitrosDisponibles());
    }

    @GetMapping("/sin-asignar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ArbitroResponse>> getArbitrosSinAsignar() {
        log.info(" Listando árbitros sin partidos asignados");
        return ResponseEntity.ok(arbitroService.getArbitrosSinPartidos());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<ArbitroResponse> obtenerArbitroPorId(@PathVariable Long id) {
        log.info(" Obteniendo árbitro por ID: {}", id);
        return ResponseEntity.ok(arbitroService.obtenerArbitroPorId(id));
    }

    @GetMapping("/username/{username}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<ArbitroResponse> obtenerArbitroPorUsername(@PathVariable String username) {
        log.info(" Obteniendo árbitro por username: {}", username);
        return ResponseEntity.ok(arbitroService.obtenerArbitroPorUsername(username));
    }

    @GetMapping("/buscar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ArbitroResponse>> buscarArbitros(@RequestParam String query) {
        log.info(" Buscando árbitros por: {}", query);
        return ResponseEntity.ok(arbitroService.buscarArbitros(query));
    }

    @GetMapping("/{id}/estadisticas")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<ArbitroEstadisticasResponse> obtenerEstadisticas(@PathVariable Long id) {
        log.info(" Obteniendo estadísticas del árbitro ID: {}", id);
        return ResponseEntity.ok(arbitroService.obtenerEstadisticas(id));
    }

    @GetMapping("/{id}/partidos-finalizados")
    @PreAuthorize("hasAnyRole('ADMIN', 'ARBITRO')")
    public ResponseEntity<List<PartidoResponse>> getPartidosFinalizados(@PathVariable Long id) {
        log.info(" Obteniendo partidos finalizados del árbitro ID: {}", id);
        return ResponseEntity.ok(arbitroService.getPartidosFinalizados(id));
    }

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ArbitroResponse> crearArbitro(@RequestBody ArbitroRequest dto) {
        log.info(" Creando nuevo árbitro: {}", dto.getUsername());
        ArbitroResponse response = arbitroService.crearArbitro(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/asignar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> asignarArbitro(@RequestBody AsignarArbitroDTO dto) {
        log.info(" Asignando árbitro {} al partido {}", dto.getArbitroId(), dto.getPartidoId());
        arbitroService.asignarArbitroAPartido(dto);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ArbitroResponse> actualizarArbitro(
            @PathVariable Long id,
            @RequestBody ArbitroRequest dto) {
        log.info(" Actualizando árbitro ID: {}", id);
        return ResponseEntity.ok(arbitroService.actualizarArbitro(id, dto));
    }

    @PatchMapping("/{id}/verificar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> verificarArbitro(@PathVariable Long id) {
        log.info(" Verificando árbitro ID: {}", id);
        arbitroService.verificarArbitro(id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> eliminarArbitro(@PathVariable Long id) {
        log.info(" Eliminando árbitro ID: {}", id);
        arbitroService.eliminarArbitro(id);
        return ResponseEntity.noContent().build();
    }
}
