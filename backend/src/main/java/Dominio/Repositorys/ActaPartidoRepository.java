package Dominio.Repositorys;

import Dominio.Entity.ActaPartido;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ActaPartidoRepository extends JpaRepository<ActaPartido, Long> {

    Optional<ActaPartido> findByPartidoId(Long partidoId);

    boolean existsByPartidoId(Long partidoId);

    List<ActaPartido> findByArbitroId(Long arbitroId);

    @Query("SELECT a FROM ActaPartido a WHERE a.partido.equipoLocal.id = :equipoId OR a.partido.equipoVisitante.id = :equipoId")
    List<ActaPartido> findByEquipoId(@Param("equipoId") Long equipoId);
}
