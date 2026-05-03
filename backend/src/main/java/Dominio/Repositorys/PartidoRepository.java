// Dominio/Repositorys/PartidoRepository.java
package Dominio.Repositorys;

import Dominio.Entity.Partido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PartidoRepository extends JpaRepository<Partido, Long> {

    // Búsquedas básicas
    List<Partido> findByEstado(String estado);

    List<Partido> findByFechaBetween(LocalDateTime inicio, LocalDateTime fin);

    List<Partido> findByEquipoLocalId(Long equipoId);

    List<Partido> findByEquipoVisitanteId(Long equipoId);

    // Búsqueda por equipo (local o visitante)
    @Query("SELECT p FROM Partido p WHERE p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId")
    List<Partido> findByEquipoLocalIdOrEquipoVisitanteId(@Param("equipoId") Long equipoId);

    // Búsqueda por árbitro
    List<Partido> findByArbitroId(Long arbitroId);

    // Búsqueda por equipo y estado
    @Query("SELECT p FROM Partido p WHERE (p.equipoLocal.id = :equipoId OR p.equipoVisitante.id = :equipoId) AND p.estado = :estado")
    List<Partido> findByEquipoIdAndEstado(@Param("equipoId") Long equipoId, @Param("estado") String estado);

    // Búsqueda de partidos pendientes (no finalizados)
    @Query("SELECT p FROM Partido p WHERE p.estado != 'FINALIZADO' ORDER BY p.fecha ASC")
    List<Partido> findPartidosPendientes();

    // Búsqueda de partidos futuros
    @Query("SELECT p FROM Partido p WHERE p.fecha > :fecha ORDER BY p.fecha ASC")
    List<Partido> findPartidosFuturos(@Param("fecha") LocalDateTime fecha);

    // Búsqueda de partidos por liga
    List<Partido> findByLigaId(Long ligaId);

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

    // CORREGIDO: Contar partidos de hoy usando LocalDate
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
}