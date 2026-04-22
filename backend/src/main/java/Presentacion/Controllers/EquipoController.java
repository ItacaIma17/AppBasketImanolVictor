// Presentacion/Controllers/EquipoController.java
package Presentacion.Controllers;

import Aplicacion.Services.EquipoService;
import Presentacion.DTOS.Equipo.ActualizarEquipoDTO;
import Presentacion.DTOS.Equipo.CrearEquipoDTO;
import Presentacion.DTOS.Equipo.EquipoRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/equipos")
@RequiredArgsConstructor
public class EquipoController {

    private final EquipoService equipoService;

    // Crear equipo (solo admin)
    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoRequest> crearEquipo(@Valid @RequestBody CrearEquipoDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(equipoService.crearEquipo(dto));
    }

    // Obtener equipo por ID
    @GetMapping("/{id}")
    public ResponseEntity<EquipoRequest> obtenerEquipoPorId(@PathVariable Long id) {
        return ResponseEntity.ok(equipoService.obtenerEquipoPorId(id));
    }

    // Obtener equipo por nombre
    @GetMapping("/buscar")
    public ResponseEntity<EquipoRequest> obtenerEquipoPorNombre(@RequestParam String nombre) {
        return ResponseEntity.ok(equipoService.obtenerEquipoPorNombre(nombre));
    }

    // Listar todos los equipos
    @GetMapping("/listar")
    public ResponseEntity<List<EquipoRequest>> listarTodosEquipos() {
        return ResponseEntity.ok(equipoService.listarTodosEquipos());
    }

    // Listar equipos por liga
    @GetMapping("/liga/{ligaId}")
    public ResponseEntity<List<EquipoRequest>> listarEquiposPorLiga(@PathVariable Long ligaId) {
        return ResponseEntity.ok(equipoService.listarEquiposPorLiga(ligaId));
    }

    // Listar equipos sin entrenador
    @GetMapping("/sin-entrenador")
    public ResponseEntity<List<EquipoRequest>> listarEquiposSinEntrenador() {
        return ResponseEntity.ok(equipoService.listarEquiposSinEntrenador());
    }

    // Actualizar equipo (solo admin)
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EquipoRequest> actualizarEquipo(
            @PathVariable Long id,
            @Valid @RequestBody ActualizarEquipoDTO dto) {
        return ResponseEntity.ok(equipoService.actualizarEquipo(id, dto));
    }

    // Eliminar equipo (solo admin)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> eliminarEquipo(@PathVariable Long id) {
        equipoService.eliminarEquipo(id);
        return ResponseEntity.noContent().build();
    }

    // Contar jugadores del equipo
    @GetMapping("/{id}/jugadores/count")
    public ResponseEntity<Integer> contarJugadores(@PathVariable Long id) {
        return ResponseEntity.ok(equipoService.contarJugadores(id));
    }
}