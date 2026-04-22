// Dominio/Repositorys/EquipoRepository.java
package Dominio.Repositorys;

import Dominio.Entity.Equipo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface EquipoRepository extends JpaRepository<Equipo, Long> {

    Optional<Equipo> findByNombre(String nombre);

    List<Equipo> findByLigaId(Long ligaId);

    List<Equipo> findByCiudad(String ciudad);

    @Query("SELECT e FROM Equipo e WHERE e.entrenador IS NULL")
    List<Equipo> findEquiposSinEntrenador();

    @Query("SELECT e FROM Equipo e WHERE e.entrenador IS NOT NULL")
    List<Equipo> findEquiposConEntrenador();

    @Query("SELECT e FROM Equipo e WHERE e.entrenador IS NULL AND e.liga.id = :ligaId")
    List<Equipo> findEquiposSinEntrenadorByLiga(@Param("ligaId") Long ligaId);

    @Query("SELECT e FROM Equipo e WHERE e.liga.id = :ligaId ORDER BY e.nombre")
    List<Equipo> findByLigaIdOrderByNombre(@Param("ligaId") Long ligaId);

    boolean existsByNombre(String nombre);

    boolean existsByEntrenadorId(Long entrenadorId);

    @Query("SELECT COUNT(j) FROM Jugador j WHERE j.equipo.id = :equipoId")
    int countJugadoresByEquipoId(@Param("equipoId") Long equipoId);
}