package Presentacion.Controllers;

import Aplicacion.Services.ArbitroService;
import Presentacion.DTOS.Arbitro.ArbitroResponse;
import Presentacion.DTOS.Arbitro.AsignarArbitroDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/arbitros")
@RequiredArgsConstructor
public class ArbitroController {

    private final ArbitroService arbitroService;

    @GetMapping("/mis-partidos")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<?> getMisPartidos(@AuthenticationPrincipal UserDetails userDetails) {
        log.info("📋 Obteniendo partidos del árbitro: {}", userDetails.getUsername());
        return ResponseEntity.ok(arbitroService.getPartidosAsignados(userDetails.getUsername()));
    }

    @GetMapping("/partido/{partidoId}/alineaciones")
    @PreAuthorize("hasRole('ARBITRO')")
    public ResponseEntity<?> getAlineacionesPartido(@PathVariable Long partidoId) {
        log.info("📋 Obteniendo alineaciones para acta del partido: {}", partidoId);
        return ResponseEntity.ok(arbitroService.getAlineacionesPartido(partidoId));
    }

    @PostMapping("/asignar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> asignarArbitro(@RequestBody AsignarArbitroDTO dto) {
        log.info("👑 Asignando árbitro {} al partido {}", dto.getArbitroId(), dto.getPartidoId());
        arbitroService.asignarArbitroAPartido(dto);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/sin-asignar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ArbitroResponse>> getArbitrosSinAsignar() {
        log.info("👑 Listando árbitros sin partidos asignados");
        return ResponseEntity.ok(arbitroService.getArbitrosSinPartidos());
    }
}