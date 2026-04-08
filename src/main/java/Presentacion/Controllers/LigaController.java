package Presentacion.Controllers;

import Aplicacion.Services.LigaService;
import Presentacion.DTOS.Liga.LigaRequest;
import Presentacion.DTOS.Liga.LigaResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ligas")
@RequiredArgsConstructor
public class LigaController {

    private final LigaService ligaService;

    @PostMapping("/crear")
    public ResponseEntity<LigaResponse> crear(@RequestBody LigaRequest dto) {
        return ResponseEntity.ok(ligaService.crearLiga(dto));
    }

    @GetMapping("/listar")
    public ResponseEntity<List<LigaResponse>> listar() {
        return ResponseEntity.ok(ligaService.listarLigas());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LigaResponse> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(ligaService.obtenerLiga(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<LigaResponse> actualizar(
            @PathVariable Long id, @RequestBody LigaRequest dto) {
        return ResponseEntity.ok(ligaService.actualizarLiga(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        ligaService.eliminarLiga(id);
        return ResponseEntity.noContent().build();
    }
}