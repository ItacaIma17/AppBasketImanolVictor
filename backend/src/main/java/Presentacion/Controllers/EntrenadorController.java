// Presentacion/Controllers/EntrenadorController.java
package Presentacion.Controllers;

import Aplicacion.Services.EntrenadorService;
import Presentacion.DTOS.Entrenador.AsignarEquipoDTO;
import Presentacion.DTOS.Entrenador.CrearEntrenadorDTO;
import Presentacion.DTOS.Entrenador.EntrenadorEquipoDTO;
import Presentacion.DTOS.Entrenador.EntrenadorRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/entrenadores")
@RequiredArgsConstructor
public class EntrenadorController {

    private final EntrenadorService entrenadorService;

    // Generar código (solo admin)
    @PostMapping("/generar-codigo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> generarCodigo() {
        String codigo = entrenadorService.generarCodigoEntrenador();
        return ResponseEntity.ok(Map.of("codigo", codigo));
    }

    // Crear entrenador (solo admin)
    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EntrenadorRequest> crearEntrenador(@Valid @RequestBody CrearEntrenadorDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(entrenadorService.crearEntrenador(dto));
    }

    // Asignar equipo a entrenador (solo admin)
    @PostMapping("/asignar-equipo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EntrenadorEquipoDTO> asignarEquipo(
            @AuthenticationPrincipal UserDetails admin,
            @RequestBody AsignarEquipoDTO dto) {
        return ResponseEntity.ok(entrenadorService.asignarEquipoAEntrenador(dto, admin.getUsername()));
    }

    // Obtener mi equipo (entrenador autenticado)
    @GetMapping("/mi-equipo")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<EntrenadorEquipoDTO> obtenerMiEquipo(
            @AuthenticationPrincipal UserDetails entrenador) {
        return ResponseEntity.ok(entrenadorService.obtenerMiEquipo(entrenador.getUsername()));
    }

    // Listar todos los entrenadores (solo admin)
    @GetMapping("/listar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EntrenadorRequest>> listarTodosEntrenadores() {
        return ResponseEntity.ok(entrenadorService.listarTodosEntrenadores());
    }

    // Listar entrenadores sin equipo (solo admin)
    @GetMapping("/sin-equipo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EntrenadorRequest>> listarEntrenadoresSinEquipo() {
        return ResponseEntity.ok(entrenadorService.listarEntrenadoresSinEquipo());
    }

    // Listar entrenadores con equipo (solo admin)
    @GetMapping("/con-equipo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EntrenadorRequest>> listarEntrenadoresConEquipo() {
        return ResponseEntity.ok(entrenadorService.listarEntrenadoresConEquipo());
    }

    // Obtener entrenador por ID (solo admin)
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EntrenadorRequest> obtenerEntrenadorPorId(@PathVariable Long id) {
        return ResponseEntity.ok(entrenadorService.obtenerEntrenadorPorId(id));
    }

    // Obtener entrenador por username
    @GetMapping("/username/{username}")
    public ResponseEntity<EntrenadorRequest> obtenerEntrenadorPorUsername(@PathVariable String username) {
        return ResponseEntity.ok(entrenadorService.obtenerEntrenadorPorUsername(username));
    }

    // Eliminar entrenador (solo admin)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> eliminarEntrenador(@PathVariable Long id) {
        entrenadorService.eliminarEntrenador(id);
        return ResponseEntity.noContent().build();
    }
}