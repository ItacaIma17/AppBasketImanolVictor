package Presentacion.Controllers;

import Aplicacion.Services.EquipoService;
import Presentacion.DTOS.Equipo.EquipoRequest;
import Presentacion.DTOS.Equipo.EquipoResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/equipos")
@RequiredArgsConstructor
public class EquipoController {

    private final EquipoService equipoService;

    @PostMapping("/crear")
    public ResponseEntity<EquipoResponse> crear(@RequestBody EquipoRequest dto) {
        return ResponseEntity.ok(equipoService.crearEquipo(dto));
    }

    @GetMapping("/listar")
    public ResponseEntity<List<EquipoResponse>> listar() {
        return ResponseEntity.ok(equipoService.listarEquipos());
    }

    @GetMapping("/liga/{ligaId}")
    public ResponseEntity<List<EquipoResponse>> listarPorLiga(@PathVariable Long ligaId) {
        return ResponseEntity.ok(equipoService.listarPorLiga(ligaId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<EquipoResponse> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(equipoService.obtenerEquipo(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<EquipoResponse> actualizar(
            @PathVariable Long id, @RequestBody EquipoRequest dto) {
        return ResponseEntity.ok(equipoService.actualizarEquipo(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        equipoService.eliminarEquipo(id);
        return ResponseEntity.noContent().build();
    }
}