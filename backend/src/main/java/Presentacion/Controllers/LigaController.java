package Presentacion.Controllers;

import Aplicacion.Services.LigaService;
import Presentacion.DTOS.Liga.LigaRequest;
import Presentacion.DTOS.Liga.LigaResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/ligas")
@RequiredArgsConstructor
public class LigaController {

    private final LigaService ligaService;

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<LigaResponse> crearLiga(@Valid @RequestBody LigaRequest dto) {
        log.info("📝 Creando nueva liga: {}", dto.getNombreLiga());
        return ResponseEntity.status(HttpStatus.CREATED).body(ligaService.crearLiga(dto));
    }

    @GetMapping("/listar")
    public ResponseEntity<List<LigaResponse>> listarLigas() {
        log.info("📋 Listando todas las ligas");
        return ResponseEntity.ok(ligaService.listarTodasLigas());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LigaResponse> obtenerLiga(@PathVariable Long id) {
        log.info("🔍 Obteniendo liga con ID: {}", id);
        return ResponseEntity.ok(ligaService.obtenerLigaPorId(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<LigaResponse> actualizarLiga(
            @PathVariable Long id,
            @Valid @RequestBody LigaRequest dto) {
        log.info("✏️ Actualizando liga ID: {}", id);
        return ResponseEntity.ok(ligaService.actualizarLiga(id, dto));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> eliminarLiga(@PathVariable Long id) {
        log.info("🗑️ Eliminando liga ID: {}", id);
        ligaService.eliminarLiga(id);
        return ResponseEntity.noContent().build();
    }
}