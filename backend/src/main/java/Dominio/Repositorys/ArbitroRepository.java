// Dominio/Repositorys/ArbitroRepository.java
package Dominio.Repositorys;

import Dominio.Entity.Arbitro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ArbitroRepository extends JpaRepository<Arbitro, Long> {

    Optional<Arbitro> findByUsername(String username);

    Optional<Arbitro> findByEmail(String email);

    Optional<Arbitro> findByCodigoArbitro(String codigoArbitro);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    boolean existsByCodigoArbitro(String codigoArbitro);

    // ✅ Método para encontrar árbitros sin partidos asignados
    @Query("SELECT a FROM Arbitro a WHERE a.id NOT IN (SELECT p.arbitro.id FROM Partido p WHERE p.arbitro IS NOT NULL AND p.estado != 'FINALIZADO')")
    List<Arbitro> findArbitrosSinPartidos();


    /**
     * Buscar árbitros por nombre o apellidos (like)
     */
    @Query("SELECT a FROM Arbitro a WHERE LOWER(a.nombre) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(a.apellidos) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(a.username) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Arbitro> buscarArbitros(@Param("query") String query);
}