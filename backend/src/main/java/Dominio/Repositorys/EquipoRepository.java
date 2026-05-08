// Dominio/Repositorys/EquipoRepository.java - VERSIÓN CORREGIDA

package Dominio.Repositorys;

import Dominio.Entity.Equipo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EquipoRepository extends JpaRepository<Equipo, Long> {

    Optional<Equipo> findByNombre(String nombre);

    List<Equipo> findByLigaId(Long ligaId);

    List<Equipo> findByCiudad(String ciudad);

    @Query("SELECT e FROM Equipo e WHERE e.entrenador IS NULL AND e.solicitudPendiente = false")
    List<Equipo> findEquiposSinEntrenador();

    @Query("SELECT e FROM Equipo e WHERE e.codigoSolicitud = :codigo")
    Optional<Equipo> findByCodigoSolicitud(@Param("codigo") String codigo);

    @Query("SELECT e FROM Equipo e WHERE e.solicitudPendiente = true")
    List<Equipo> findEquiposConSolicitudPendiente();

    // ✅ MÉTODO CORRECTO - Contar equipos por liga
    @Query("SELECT COUNT(e) FROM Equipo e WHERE e.liga.id = :ligaId")
    long countByLigaId(@Param("ligaId") Long ligaId);
}