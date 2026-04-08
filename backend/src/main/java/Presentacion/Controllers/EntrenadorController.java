package Presentacion.Controllers;

import Aplicacion.Services.EntrenadorService;
import Dominio.Entity.Entrenador;
import Presentacion.DTOS.Entrenador.EntrenadorRequest;
import Presentacion.DTOS.Entrenador.EntrenadorResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/entrenadores")
@RequiredArgsConstructor
public class EntrenadorController {

    private final EntrenadorService entrenadorService;

    @GetMapping("/listar")
    public ResponseEntity<List<EntrenadorResponse>> listar() {
        return ResponseEntity.ok(entrenadorService.listar());
    }

    @GetMapping("/{id}")
    public ResponseEntity<EntrenadorResponse> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(entrenadorService.obtenerPorId(id));
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<Entrenador> obtenerPorCodigo(@PathVariable String codigo) {
        return ResponseEntity.ok(entrenadorService.obtenerPorCodigo(codigo));
    }

    @PutMapping("/{id}")
    public ResponseEntity<EntrenadorResponse> actualizar(
            @PathVariable Long id,
            @RequestBody EntrenadorRequest dto) {
        return ResponseEntity.ok(entrenadorService.actualizar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        entrenadorService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}