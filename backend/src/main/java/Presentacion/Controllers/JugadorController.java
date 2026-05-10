package Presentacion.Controllers;

import Aplicacion.Services.JugadorService;
import Dominio.Entity.Jugador;
import Presentacion.DTOS.Jugador.JugadorRequest;
import Presentacion.DTOS.Jugador.JugadorResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/jugadores")
@RequiredArgsConstructor
@Slf4j
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

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<JugadorResponse> crearJugador(@RequestBody JugadorRequest dto) {
        log.info(" Creando nuevo jugador: {}", dto.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(jugadorService.crearJugador(dto));
    }

    @GetMapping("/buscar")
    @PreAuthorize("hasAnyRole('ADMIN', 'ENTRENADOR')")
    public ResponseEntity<List<JugadorResponse>> buscarJugadores(@RequestParam String q) {
        log.info(" Buscando jugadores por: {}", q);
        return ResponseEntity.ok(jugadorService.buscarJugadores(q));
    }

    @GetMapping("/ranking/puntos")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<JugadorResponse>> rankingPuntos(
            @RequestParam(defaultValue = "10") int limit) {
        log.info(" Top {} jugadores por puntos", limit);
        return ResponseEntity.ok(jugadorService.getRankingPuntos(limit));
    }

    @GetMapping("/ranking/rebotes")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<JugadorResponse>> rankingRebotes(
            @RequestParam(defaultValue = "10") int limit) {
        log.info(" Top {} jugadores por rebotes", limit);
        return ResponseEntity.ok(jugadorService.getRankingRebotes(limit));
    }

    @GetMapping("/ranking/asistencias")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<JugadorResponse>> rankingAsistencias(
            @RequestParam(defaultValue = "10") int limit) {
        log.info(" Top {} jugadores por asistencias", limit);
        return ResponseEntity.ok(jugadorService.getRankingAsistencias(limit));
    }

    @PutMapping("/{id}/asignar-equipo/{equipoId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<JugadorResponse> asignarEquipo(
            @PathVariable Long id,
            @PathVariable Long equipoId) {
        log.info(" Asignando jugador {} al equipo {}", id, equipoId);
        return ResponseEntity.ok(jugadorService.asignarEquipo(id, equipoId));
    }

    @DeleteMapping("/{id}/desasignar-equipo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<JugadorResponse> desasignarEquipo(@PathVariable Long id) {
        log.info(" Desasignando equipo del jugador {}", id);
        return ResponseEntity.ok(jugadorService.desasignarEquipo(id));
    }

    @GetMapping("/username/{username}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<JugadorResponse> obtenerPorUsername(@PathVariable String username) {
        log.info(" Obteniendo jugador por username: {}", username);
        return ResponseEntity.ok(jugadorService.obtenerPorUsername(username));
    }

    @GetMapping("/destacados")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<JugadorResponse>> getJugadoresDestacados(
            @RequestParam(defaultValue = "5") int limit) {
        log.info("⭐ Obteniendo top {} jugadores destacados", limit);
        return ResponseEntity.ok(jugadorService.getJugadoresDestacados(limit));
    }

    @GetMapping("/{id}/estadisticas-completas")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getEstadisticasCompletas(@PathVariable Long id) {
        log.info(" Obteniendo estadísticas completas del jugador {}", id);
        return ResponseEntity.ok(jugadorService.getEstadisticasCompletas(id));
    }
}
