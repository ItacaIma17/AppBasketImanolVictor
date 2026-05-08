package Presentacion.Controllers;

import Aplicacion.Services.EstadisticasService;
import Dominio.Entity.Jugador;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.JugadorRepository;
import Dominio.Repositorys.PartidoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/estadisticas")
@RequiredArgsConstructor
public class EstadisticasController {

    private final EstadisticasService estadisticasService;
    private final JugadorRepository jugadorRepository;
    private final EquipoRepository equipoRepository;
    private final PartidoRepository partidoRepository;

    // ============================================================
    // ESTADÍSTICAS GLOBALES (desde Service)
    // ============================================================

    @GetMapping("/globales")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getEstadisticasGlobales() {
        log.info("📊 Obteniendo estadísticas globales");
        return ResponseEntity.ok(estadisticasService.getEstadisticasCompletas());
    }

    @GetMapping("/rapidas")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getEstadisticasRapidas() {
        log.info("📊 Obteniendo estadísticas rápidas");
        return ResponseEntity.ok(estadisticasService.getEstadisticasRapidas());
    }

    // ============================================================
    // ESTADÍSTICAS DE JUGADOR
    // ============================================================

    @GetMapping("/jugador/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getEstadisticasJugador(@PathVariable Long id) {
        log.info("📊 Estadísticas del jugador ID: {}", id);

        Jugador jugador = jugadorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Jugador no encontrado"));

        return ResponseEntity.ok(buildJugadorStats(jugador));
    }

    @GetMapping("/jugadores/top")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Map<String, Object>>> getTopJugadores(
            @RequestParam(defaultValue = "puntos") String ordenar,
            @RequestParam(defaultValue = "10") int limite) {

        log.info("📊 Top {} jugadores por {}", limite, ordenar);

        List<Jugador> jugadores = jugadorRepository.findAll();
        List<Map<String, Object>> ranking = jugadores.stream()
                .map(this::buildJugadorStats)
                .sorted((a, b) -> {
                    switch (ordenar.toLowerCase()) {
                        case "rebotes": return Integer.compare(
                                (int) b.get("rebotesTotales"), (int) a.get("rebotesTotales"));
                        case "asistencias": return Integer.compare(
                                (int) b.get("asistenciasTotales"), (int) a.get("asistenciasTotales"));
                        case "robos": return Integer.compare(
                                (int) b.get("robosTotales"), (int) a.get("robosTotales"));
                        default: return Integer.compare(
                                (int) b.get("puntosTotales"), (int) a.get("puntosTotales"));
                    }
                })
                .limit(limite)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ranking);
    }

    // ============================================================
    // CLASIFICACIÓN POR LIGA
    // ============================================================

    @GetMapping("/clasificacion/{ligaId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Map<String, Object>>> getClasificacion(@PathVariable Long ligaId) {
        log.info("📊 Clasificación de la liga ID: {}", ligaId);

        var partidos = partidoRepository.findByLigaId(ligaId);
        var equiposStats = new HashMap<Long, Map<String, Object>>();

        for (var partido : partidos) {
            if (!"FINALIZADO".equals(partido.getEstado())) continue;
            if (partido.getResultadoLocal() == null || partido.getResultadoVisitante() == null) continue;

            Long localId = partido.getEquipoLocal().getId();
            Long visitanteId = partido.getEquipoVisitante().getId();

            var statsLocal = equiposStats.computeIfAbsent(localId, k -> {
                Map<String, Object> s = new LinkedHashMap<>();
                s.put("id", k);
                s.put("nombre", partido.getEquipoLocal().getNombre());
                s.put("pj", 0); s.put("pg", 0); s.put("pp", 0);
                s.put("pf", 0); s.put("pc", 0); s.put("puntos", 0);
                return s;
            });

            var statsVisitante = equiposStats.computeIfAbsent(visitanteId, k -> {
                Map<String, Object> s = new LinkedHashMap<>();
                s.put("id", k);
                s.put("nombre", partido.getEquipoVisitante().getNombre());
                s.put("pj", 0); s.put("pg", 0); s.put("pp", 0);
                s.put("pf", 0); s.put("pc", 0); s.put("puntos", 0);
                return s;
            });

            actualizarStats(statsLocal, partido.getResultadoLocal(), partido.getResultadoVisitante());
            actualizarStats(statsVisitante, partido.getResultadoVisitante(), partido.getResultadoLocal());
        }

        var clasificacion = new ArrayList<>(equiposStats.values());
        clasificacion.sort((a, b) -> {
            int puntosA = (int) a.get("puntos");
            int puntosB = (int) b.get("puntos");
            if (puntosA != puntosB) return puntosB - puntosA;
            int difA = (int) a.get("pf") - (int) a.get("pc");
            int difB = (int) b.get("pf") - (int) b.get("pc");
            return difB - difA;
        });

        for (int i = 0; i < clasificacion.size(); i++) {
            clasificacion.get(i).put("posicion", i + 1);
        }

        return ResponseEntity.ok(clasificacion);
    }

    // ============================================================
    // ESTADÍSTICAS DE EQUIPO
    // ============================================================

    @GetMapping("/equipo/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> getEstadisticasEquipo(@PathVariable Long id) {
        log.info("📊 Estadísticas del equipo ID: {}", id);

        var equipo = equipoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Equipo no encontrado"));

        var partidos = partidoRepository.findAll().stream()
                .filter(p -> p.participaEquipo(equipo))
                .collect(Collectors.toList());

        int pj = 0, pg = 0, pp = 0, pf = 0, pc = 0;
        for (var partido : partidos) {
            if (!"FINALIZADO".equals(partido.getEstado())) continue;
            if (partido.getResultadoLocal() == null || partido.getResultadoVisitante() == null) continue;
            pj++;
            boolean esLocal = partido.getEquipoLocal().getId().equals(id);
            int propios = esLocal ? partido.getResultadoLocal() : partido.getResultadoVisitante();
            int contrarios = esLocal ? partido.getResultadoVisitante() : partido.getResultadoLocal();
            pf += propios;
            pc += contrarios;
            if (propios > contrarios) pg++;
            else pp++;
        }

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("id", id);
        stats.put("nombre", equipo.getNombre());
        stats.put("pj", pj);
        stats.put("pg", pg);
        stats.put("pp", pp);
        stats.put("pf", pf);
        stats.put("pc", pc);
        stats.put("diferencia", pf - pc);
        stats.put("porcentajeVictorias", pj > 0 ? Math.round((double) pg / pj * 100) : 0);

        var jugadores = jugadorRepository.findByEquipoId(id);
        stats.put("jugadores", jugadores.stream()
                .map(this::buildJugadorStats)
                .collect(Collectors.toList()));

        return ResponseEntity.ok(stats);
    }

    // ============================================================
    // MÉTODOS PRIVADOS
    // ============================================================

    private Map<String, Object> buildJugadorStats(Jugador j) {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("id", j.getId());
        stats.put("nombre", j.getNombre());
        stats.put("apellido", j.getApellido());
        stats.put("dorsal", j.getDorsal());
        stats.put("posicion", j.getPosicion());
        stats.put("equipoNombre", j.getEquipo() != null ? j.getEquipo().getNombre() : null);
        stats.put("puntosTotales", j.getPuntosTotales());
        stats.put("rebotesTotales", j.getRebotesTotales());
        stats.put("asistenciasTotales", j.getAsistenciasTotales());
        stats.put("robosTotales", j.getRobosTotales());
        stats.put("partidosJugados", j.getPartidosJugados());

        if (j.getPartidosJugados() > 0) {
            stats.put("mediaPuntos", Math.round((double) j.getPuntosTotales() / j.getPartidosJugados() * 10.0) / 10.0);
            stats.put("mediaRebotes", Math.round((double) j.getRebotesTotales() / j.getPartidosJugados() * 10.0) / 10.0);
            stats.put("mediaAsistencias", Math.round((double) j.getAsistenciasTotales() / j.getPartidosJugados() * 10.0) / 10.0);
            stats.put("mediaRobos", Math.round((double) j.getRobosTotales() / j.getPartidosJugados() * 10.0) / 10.0);
        } else {
            stats.put("mediaPuntos", 0.0);
            stats.put("mediaRebotes", 0.0);
            stats.put("mediaAsistencias", 0.0);
            stats.put("mediaRobos", 0.0);
        }

        return stats;
    }

    private void actualizarStats(Map<String, Object> stats, int puntosPropios, int puntosContrarios) {
        stats.put("pj", (int) stats.get("pj") + 1);
        stats.put("pf", (int) stats.get("pf") + puntosPropios);
        stats.put("pc", (int) stats.get("pc") + puntosContrarios);
        if (puntosPropios > puntosContrarios) {
            stats.put("pg", (int) stats.get("pg") + 1);
            stats.put("puntos", (int) stats.get("puntos") + 2);
        } else {
            stats.put("pp", (int) stats.get("pp") + 1);
            stats.put("puntos", (int) stats.get("puntos") + 1);
        }
    }
}