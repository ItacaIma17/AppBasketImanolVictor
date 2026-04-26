// Dominio/Repositorys/LigaRepository.java
package Dominio.Repositorys;

import Dominio.Entity.Liga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface LigaRepository extends JpaRepository<Liga, Long> {

    Optional<Liga> findByNombreLiga(String nombreLiga);

    boolean existsByNombreLiga(String nombreLiga);

    @Query("SELECT l FROM Liga l LEFT JOIN FETCH l.equipos WHERE l.id = :id")
    Optional<Liga> findByIdWithEquipos(@Param("id") Long id);
}