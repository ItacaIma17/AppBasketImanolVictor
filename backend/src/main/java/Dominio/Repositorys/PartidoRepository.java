// Dominio/Repositorys/PartidoRepository.java

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

    // Búsquedas básicas
    List<Partido> findByEstado(String estado);
    List<Partido> findByFechaBetween(LocalDateTime inicio, LocalDateTime fin);
    List<Partido> findByEquipoLocalId(Long equipoId);
    List<Partido> findByEquipoVisitanteId(Long equipoId);
    List<Partido> findByArbitroId(Long arbitroId);
    List<Partido> findByLigaId(Long ligaId);

    // Búsqueda por equipo (local o visitante)
    @Query("SELECT p FROM Partido p WHERE p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId")
    List<Partido> findByEquipoLocalIdOrEquipoVisitanteId(@Param("equipoId") Long equipoId);

    // Búsqueda por equipo y estado
    @Query("SELECT p FROM Partido p WHERE (p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId) AND p.estado = :estado")
    List<Partido> findByEquipoIdAndEstado(@Param("equipoId") Long equipoId, @Param("estado") String estado);

    // Búsqueda de partidos pendientes (no finalizados)
    @Query("SELECT p FROM Partido p WHERE p.estado != 'FINALIZADO' ORDER BY p.fecha ASC")
    List<Partido> findPartidosPendientes();

    // Búsqueda de partidos futuros
    @Query("SELECT p FROM Partido p WHERE p.fecha > :fecha ORDER BY p.fecha ASC")
    List<Partido> findPartidosFuturos(@Param("fecha") LocalDateTime fecha);

    // Verificar si existe un partido entre dos equipos
    @Query("SELECT COUNT(p) > 0 FROM Partido p WHERE " +
            "(p.equipoLocal.id = :equipoLocalId AND p.equipoVisitante.id = :equipoVisitanteId) OR " +
            "(p.equipoLocal.id = :equipoVisitanteId AND p.equipoVisitante.id = :equipoLocalId)")
    boolean existsPartidoEntreEquipos(@Param("equipoLocalId") Long equipoLocalId,
                                      @Param("equipoVisitanteId") Long equipoVisitanteId);

    // Obtener próximos partidos de un equipo (máximo 5)
    @Query("SELECT p FROM Partido p WHERE (p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId) " +
            "AND p.fecha > :fecha AND p.estado != 'FINALIZADO' ORDER BY p.fecha ASC LIMIT 5")
    List<Partido> findProximosPartidosByEquipo(@Param("equipoId") Long equipoId,
                                               @Param("fecha") LocalDateTime fecha);

    // Contar partidos de hoy
    @Query("SELECT COUNT(p) FROM Partido p WHERE FUNCTION('DATE', p.fecha) = CURRENT_DATE")
    long countPartidosHoy();

    // Contar partidos por estado
    long countByEstado(String estado);

    // Obtener últimos 5 partidos ordenados por fecha descendente
    List<Partido> findTop5ByOrderByFechaDesc();

    // Buscar partido entre dos equipos específicos
    @Query("SELECT p FROM Partido p WHERE " +
            "(p.equipoLocal.id = :equipoLocalId AND p.equipoVisitante.id = :equipoVisitanteId) OR " +
            "(p.equipoLocal.id = :equipoVisitanteId AND p.equipoVisitante.id = :equipoLocalId)")
    Optional<Partido> findPartidoEntreEquipos(@Param("equipoLocalId") Long equipoLocalId,
                                              @Param("equipoVisitanteId") Long equipoVisitanteId);

    // ============================================================
    // MÉTODOS PARA ESTADÍSTICAS DE PARTIDOS POR MES
    // ============================================================

    /**
     * Cuenta los partidos agrupados por mes para los últimos 6 meses
     * Retorna una lista de objetos donde cada objeto es [año, mes, cantidad]
     */
    @Query("SELECT YEAR(p.fecha) as anio, MONTH(p.fecha) as mes, COUNT(p) as cantidad " +
            "FROM Partido p " +
            "WHERE p.fecha >= :fechaInicio " +
            "GROUP BY YEAR(p.fecha), MONTH(p.fecha) " +
            "ORDER BY anio DESC, mes DESC")
    List<Object[]> countPartidosGroupedByMonth(@Param("fechaInicio") LocalDateTime fechaInicio);

    /**
     * Cuenta los partidos agrupados por mes para los últimos 6 meses usando formato de fecha específico para MySQL
     */
    @Query(value = "SELECT DATE_FORMAT(p.fecha, '%Y-%m') as mes, COUNT(p.id) as cantidad " +
            "FROM partidos p " +
            "WHERE p.fecha >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
            "GROUP BY DATE_FORMAT(p.fecha, '%Y-%m') " +
            "ORDER BY mes DESC", nativeQuery = true)
    List<Object[]> countPartidosByLast6MonthsNative();

    /**
     * Método default que retorna un Map con los partidos de los últimos 6 meses
     * Formato: "2024-01" -> 5 (partidos)
     */
    default Map<String, Long> countPartidosByLast6Months() {
        LocalDateTime seisMesesAtras = LocalDateTime.now().minusMonths(6);
        List<Object[]> results = countPartidosGroupedByMonth(seisMesesAtras);
        Map<String, Long> result = new HashMap<>();

        for (Object[] row : results) {
            // row[0] = año, row[1] = mes, row[2] = cantidad
            Integer anio = (Integer) row[0];
            Integer mes = (Integer) row[1];
            Long cantidad = (Long) row[2];

            // Formatear como "YYYY-MM"
            String mesFormateado = String.format("%d-%02d", anio, mes);
            result.put(mesFormateado, cantidad);
        }

        return result;
    }

    /**
     * Versión alternativa usando native query que retorna Map con formato "YYYY-MM"
     */
    default Map<String, Long> countPartidosByLast6MonthsWithNativeQuery() {
        List<Object[]> results = countPartidosByLast6MonthsNative();
        Map<String, Long> result = new HashMap<>();

        for (Object[] row : results) {
            String mes = (String) row[0];  // Formato: "2024-01"
            Long cantidad = ((Number) row[1]).longValue();
            result.put(mes, cantidad);
        }

        return result;
    }

    /**
     * Cuenta partidos por mes específico
     */
    @Query("SELECT COUNT(p) FROM Partido p WHERE YEAR(p.fecha) = :anio AND MONTH(p.fecha) = :mes")
    long countPartidosByMonth(@Param("anio") int anio, @Param("mes") int mes);

    /**
     * Cuenta partidos por año
     */
    @Query("SELECT YEAR(p.fecha), COUNT(p) FROM Partido p GROUP BY YEAR(p.fecha) ORDER BY YEAR(p.fecha) DESC")
    List<Object[]> countPartidosByYear();

    /**
     * Obtiene estadísticas completas de partidos por mes para gráficos
     */
    default Map<String, Map<String, Long>> getEstadisticasPartidosPorMes() {
        Map<String, Map<String, Long>> estadisticas = new HashMap<>();

        LocalDateTime inicio = LocalDateTime.now().minusMonths(11); // Últimos 12 meses
        List<Object[]> results = countPartidosGroupedByMonth(inicio);

        for (Object[] row : results) {
            Integer anio = (Integer) row[0];
            Integer mes = (Integer) row[1];
            Long total = (Long) row[2];

            String mesKey = String.format("%d-%02d", anio, mes);
            Map<String, Long> data = new HashMap<>();
            data.put("total", total);

            // Contar por estado si es necesario
            estadisticas.put(mesKey, data);
        }

        return estadisticas;
    }

    /**
     * Obtiene los últimos N meses con datos
     */
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

    /// buscar partido que existe por jornada y equipo
    @Query("SELECT COUNT(p) > 0 FROM Partido p WHERE " +
            "(p.equipoLocal.id = :equipoLocalId AND p.equipoVisitante.id = :equipoVisitanteId) OR " +
            "(p.equipoLocal.id = :equipoVisitanteId AND p.equipoVisitante.id = :equipoLocalId) " +
            "AND p.jornada = :jornada")
    boolean existsByEquiposAndJornada(Long equipoLocalId, Long equipoVisitanteId, Integer jornada);


    /**
     * Encontrar partidos por árbitro ID y estado FINALIZADO
     */
    List<Partido> findByArbitroIdAndEstado(Long arbitroId, String estado);


    @Query("SELECT COUNT(p) FROM Partido p WHERE p.fecha BETWEEN :inicio AND :fin")
    long countByFechaBetween(@Param("inicio") LocalDateTime inicio, @Param("fin") LocalDateTime fin);


}