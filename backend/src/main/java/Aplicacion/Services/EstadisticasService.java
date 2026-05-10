package Aplicacion.Services;

import Dominio.Repositorys.*;
import Presentacion.DTOS.Partido.PartidoResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EstadisticasService {

    private final UserRepository usuarioRepository;
    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;
    private final PartidoRepository partidoRepository;
    private final EntrenadorRepository entrenadorRepository;
    private final JugadorRepository jugadorRepository;
    private final ArbitroRepository arbitroRepository;

    @Transactional(readOnly = true)
    public Map<String, Object> getEstadisticasCompletas() {
        log.info(" Obteniendo estadísticas completas del dashboard");

        Map<String, Object> stats = new LinkedHashMap<>();

        stats.put("totalUsuarios", usuarioRepository.count());
        stats.put("totalJugadores", jugadorRepository.count());
        stats.put("totalEntrenadores", entrenadorRepository.count());
        stats.put("totalArbitros", arbitroRepository.count());
        stats.put("totalEquipos", equipoRepository.count());
        stats.put("totalLigas", ligaRepository.count());
        stats.put("totalPartidos", partidoRepository.count());

        stats.put("partidosProgramados", partidoRepository.countByEstado("PROGRAMADO"));
        stats.put("partidosFinalizados", partidoRepository.countByEstado("FINALIZADO"));
        stats.put("partidosEnCurso", partidoRepository.countByEstado("EN_CURSO"));

        stats.put("ultimosPartidos", partidoRepository.findTop5ByOrderByFechaDesc()
                .stream().map(PartidoResponse::fromEntity).collect(Collectors.toList()));

        Map<String, Long> equiposPorLiga = new HashMap<>();
        ligaRepository.findAll().forEach(liga -> {
            long count = equipoRepository.countByLigaId(liga.getId());
            if (count > 0) {
                equiposPorLiga.put(liga.getNombreLiga(), count);
            }
        });
        stats.put("equiposPorLiga", equiposPorLiga);

        return stats;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getEstadisticasRapidas() {
        Map<String, Object> stats = new HashMap<>();

        stats.put("totalUsuarios", usuarioRepository.count());
        stats.put("totalEquipos", equipoRepository.count());
        stats.put("totalLigas", ligaRepository.count());
        stats.put("totalPartidosHoy", contarPartidosHoy());
        stats.put("partidosPendientes", partidoRepository.countByEstado("PROGRAMADO"));

        double porcentajeOcupacion = calcularPorcentajeOcupacionLigas();
        stats.put("porcentajeOcupacionLigas", porcentajeOcupacion);

        return stats;
    }

    private long contarPartidosHoy() {
        LocalDate hoy = LocalDate.now();
        LocalDateTime inicio = hoy.atStartOfDay();
        LocalDateTime fin = hoy.plusDays(1).atStartOfDay();
        return partidoRepository.countByFechaBetween(inicio, fin);
    }

    private double calcularPorcentajeOcupacionLigas() {
        long totalLigas = ligaRepository.count();
        if (totalLigas == 0) return 0.0;

        long ligasConEquipos = ligaRepository.countLigasConEquipos();
        return (ligasConEquipos * 100.0) / totalLigas;
    }
}
