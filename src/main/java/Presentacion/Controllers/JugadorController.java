package Presentacion.Controllers;

import Aplicacion.Services.JugadorService;
import Dominio.Entity.Jugador;
import Presentacion.DTOS.Jugador.JugadorRequest;
import Presentacion.DTOS.Jugador.JugadorResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/jugadores")
@RequiredArgsConstructor
public class JugadorController {

    private final JugadorService jugadorService;

    @GetMapping("/listar")
    public ResponseEntity<List<JugadorResponse>> listar() {
        return ResponseEntity.ok(jugadorService.listar());
    }

    @GetMapping("/{id}")
    public ResponseEntity<JugadorResponse> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(jugadorService.obtenerPorId(id));
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<Jugador> obtenerPorCodigo(@PathVariable String codigo) {
        return ResponseEntity.ok(jugadorService.obtenerPorCodigo(codigo));
    }

    @GetMapping("/equipo/{equipoId}")
    public ResponseEntity<List<JugadorResponse>> listarPorEquipo(
            @PathVariable Long equipoId) {
        return ResponseEntity.ok(jugadorService.listarPorEquipo(equipoId));
    }

    @GetMapping("/sin-equipo")
    public ResponseEntity<List<JugadorResponse>> listarSinEquipo() {
        return ResponseEntity.ok(jugadorService.listarSinEquipo());
    }

    @GetMapping("/posicion/{posicion}")
    public ResponseEntity<List<JugadorResponse>> listarPorPosicion(
            @PathVariable String posicion) {
        return ResponseEntity.ok(jugadorService.listarPorPosicion(posicion));
    }

    @PutMapping("/{id}")
    public ResponseEntity<JugadorResponse> actualizar(
            @PathVariable Long id,
            @RequestBody JugadorRequest dto) {
        return ResponseEntity.ok(jugadorService.actualizar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        jugadorService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}