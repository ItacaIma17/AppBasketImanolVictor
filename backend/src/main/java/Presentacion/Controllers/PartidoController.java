package Presentacion.Controllers;

import Aplicacion.Services.PartidoService;
import Presentacion.DTOS.Partido.PartidoResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/partidos")
@RequiredArgsConstructor
public class PartidoController {

    private final PartidoService partidoService;

    @GetMapping("/listar")
    public ResponseEntity<List<PartidoResponse>> listar() {
        return ResponseEntity.ok(partidoService.listarPartidos());
    }

    @GetMapping("/equipo-local/{id}")
    public ResponseEntity<List<PartidoResponse>> obtenerPorEquipoLocal(@PathVariable Long id) {
        return ResponseEntity.ok(partidoService.obtenerPorEquipoLocal(id));
    }

    @GetMapping("/equipo-visitante/{id}")
    public ResponseEntity<List<PartidoResponse>> obtenerPorEquipoVisitante(@PathVariable Long id) {
        return ResponseEntity.ok(partidoService.obtenerPorEquipoVisitante(id));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PartidoResponse> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(partidoService.obtenerPorId(id));
    }

    @PostMapping("/crear")
    public ResponseEntity<PartidoResponse> crear(@RequestBody PartidoResponse dto) {
        return ResponseEntity.ok(partidoService.crear(dto));
    }

    @PutMapping("/{id}/resultado")
    public ResponseEntity<PartidoResponse> actualizarResultado(
            @PathVariable Long id,
            @RequestBody PartidoResponse dto
    ) {
        return ResponseEntity.ok(partidoService.actualizarResultado(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        partidoService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
