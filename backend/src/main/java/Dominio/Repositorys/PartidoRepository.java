package Dominio.Repositorys;

import Dominio.Entity.Partido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Repository
public interface PartidoRepository extends JpaRepository<Partido, Long> {

    List<Partido> findByEstado(String estado);
    List<Partido> findByFechaBetween(LocalDateTime inicio, LocalDateTime fin);
    List<Partido> findByEquipoLocalId(Long equipoId);
    List<Partido> findByEquipoVisitanteId(Long equipoId);
    List<Partido> findByArbitroId(Long arbitroId);
    List<Partido> findByLigaId(Long ligaId);

    @Query("SELECT p FROM Partido p WHERE p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId")
    List<Partido> findByEquipoLocalIdOrEquipoVisitanteId(@Param("equipoId") Long equipoId);

    @Query("SELECT p FROM Partido p WHERE (p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId) AND p.estado = :estado")
    List<Partido> findByEquipoIdAndEstado(@Param("equipoId") Long equipoId, @Param("estado") String estado);

    @Query("SELECT p FROM Partido p WHERE p.estado != 'FINALIZADO' ORDER BY p.fecha ASC")
    List<Partido> findPartidosPendientes();

    @Query("SELECT p FROM Partido p WHERE p.fecha > :fecha ORDER BY p.fecha ASC")
    List<Partido> findPartidosFuturos(@Param("fecha") LocalDateTime fecha);

    @Query("SELECT COUNT(p) > 0 FROM Partido p WHERE " +
            "(p.equipoLocal.id = :equipoLocalId AND p.equipoVisitante.id = :equipoVisitanteId) OR " +
            "(p.equipoLocal.id = :equipoVisitanteId AND p.equipoVisitante.id = :equipoLocalId)")
    boolean existsPartidoEntreEquipos(@Param("equipoLocalId") Long equipoLocalId,
                                      @Param("equipoVisitanteId") Long equipoVisitanteId);

    @Query("SELECT p FROM Partido p WHERE (p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId) " +
            "AND p.fecha > :fecha AND p.estado != 'FINALIZADO' ORDER BY p.fecha ASC LIMIT 5")
    List<Partido> findProximosPartidosByEquipo(@Param("equipoId") Long equipoId,
                                               @Param("fecha") LocalDateTime fecha);

    @Query("SELECT COUNT(p) FROM Partido p WHERE FUNCTION('DATE', p.fecha) = CURRENT_DATE")
    long countPartidosHoy();

    long countByEstado(String estado);

    List<Partido> findTop5ByOrderByFechaDesc();

    @Query("SELECT p FROM Partido p WHERE " +
            "(p.equipoLocal.id = :equipoLocalId AND p.equipoVisitante.id = :equipoVisitanteId) OR " +
            "(p.equipoLocal.id = :equipoVisitanteId AND p.equipoVisitante.id = :equipoLocalId)")
    Optional<Partido> findPartidoEntreEquipos(@Param("equipoLocalId") Long equipoLocalId,
                                              @Param("equipoVisitanteId") Long equipoVisitanteId);

    @Query("SELECT YEAR(p.fecha) as anio, MONTH(p.fecha) as mes, COUNT(p) as cantidad " +
            "FROM Partido p " +
            "WHERE p.fecha >= :fechaInicio " +
            "GROUP BY YEAR(p.fecha), MONTH(p.fecha) " +
            "ORDER BY anio DESC, mes DESC")
    List<Object[]> countPartidosGroupedByMonth(@Param("fechaInicio") LocalDateTime fechaInicio);

    @Query(value = "SELECT DATE_FORMAT(p.fecha, '%Y-%m') as mes, COUNT(p.id) as cantidad " +
            "FROM partidos p " +
            "WHERE p.fecha >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
            "GROUP BY DATE_FORMAT(p.fecha, '%Y-%m') " +
            "ORDER BY mes DESC", nativeQuery = true)
    List<Object[]> countPartidosByLast6MonthsNative();

    default Map<String, Long> countPartidosByLast6Months() {
        LocalDateTime seisMesesAtras = LocalDateTime.now().minusMonths(6);
        List<Object[]> results = countPartidosGroupedByMonth(seisMesesAtras);
        Map<String, Long> result = new HashMap<>();

        for (Object[] row : results) {

            Integer anio = (Integer) row[0];
            Integer mes = (Integer) row[1];
            Long cantidad = (Long) row[2];

            String mesFormateado = String.format("%d-%02d", anio, mes);
            result.put(mesFormateado, cantidad);
        }

        return result;
    }

    default Map<String, Long> countPartidosByLast6MonthsWithNativeQuery() {
        List<Object[]> results = countPartidosByLast6MonthsNative();
        Map<String, Long> result = new HashMap<>();

        for (Object[] row : results) {
            String mes = (String) row[0];
            Long cantidad = ((Number) row[1]).longValue();
            result.put(mes, cantidad);
        }

        return result;
    }

    @Query("SELECT COUNT(p) FROM Partido p WHERE YEAR(p.fecha) = :anio AND MONTH(p.fecha) = :mes")
    long countPartidosByMonth(@Param("anio") int anio, @Param("mes") int mes);

    @Query("SELECT YEAR(p.fecha), COUNT(p) FROM Partido p GROUP BY YEAR(p.fecha) ORDER BY YEAR(p.fecha) DESC")
    List<Object[]> countPartidosByYear();

    default Map<String, Map<String, Long>> getEstadisticasPartidosPorMes() {
        Map<String, Map<String, Long>> estadisticas = new HashMap<>();

        LocalDateTime inicio = LocalDateTime.now().minusMonths(11);
        List<Object[]> results = countPartidosGroupedByMonth(inicio);

        for (Object[] row : results) {
            Integer anio = (Integer) row[0];
            Integer mes = (Integer) row[1];
            Long total = (Long) row[2];

            String mesKey = String.format("%d-%02d", anio, mes);
            Map<String, Long> data = new HashMap<>();
            data.put("total", total);

            estadisticas.put(mesKey, data);
        }

        return estadisticas;
    }

    default List<String> getUltimosMesesConPartidos(int cantidadMeses) {
        LocalDateTime inicio = LocalDateTime.now().minusMonths(cantidadMeses);
        List<Object[]> results = countPartidosGroupedByMonth(inicio);
        List<String> meses = new ArrayList<>();

        for (Object[] row : results) {
            Integer anio = (Integer) row[0];
            Integer mes = (Integer) row[1];
            meses.add(String.format("%d-%02d", anio, mes));
        }

        return meses;
    }

    @Query("SELECT COUNT(p) > 0 FROM Partido p WHERE " +
            "(p.equipoLocal.id = :equipoLocalId AND p.equipoVisitante.id = :equipoVisitanteId) OR " +
            "(p.equipoLocal.id = :equipoVisitanteId AND p.equipoVisitante.id = :equipoLocalId) " +
            "AND p.jornada = :jornada")
    boolean existsByEquiposAndJornada(Long equipoLocalId, Long equipoVisitanteId, Integer jornada);

    List<Partido> findByArbitroIdAndEstado(Long arbitroId, String estado);

    @Query("SELECT COUNT(p) FROM Partido p WHERE p.fecha BETWEEN :inicio AND :fin")
    long countByFechaBetween(@Param("inicio") LocalDateTime inicio, @Param("fin") LocalDateTime fin);

    @Query("SELECT p FROM Partido p WHERE p.fecha BETWEEN :inicio AND :fin AND p.estado != 'FINALIZADO'")
    List<Partido> findPartidosEntreFechas(@Param("inicio") LocalDateTime inicio, @Param("fin") LocalDateTime fin);

}
