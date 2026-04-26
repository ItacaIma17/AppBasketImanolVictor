package Dominio.Repositorys;

import Dominio.Entity.Alineacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlineacionRepository extends JpaRepository<Alineacion, Long> {

    Optional<Alineacion> findByPartidoIdAndEquipoId(Long partidoId, Long equipoId);

    @Query("SELECT a FROM Alineacion a WHERE a.partido.id = :partidoId")
    List<Alineacion> findByPartidoId(@Param("partidoId") Long partidoId);

    @Query("SELECT a FROM Alineacion a WHERE a.equipo.id = :equipoId")
    List<Alineacion> findByEquipoId(@Param("equipoId") Long equipoId);

    @Query("SELECT a FROM Alineacion a WHERE a.partido.id = :partidoId AND a.confirmada = true")
    List<Alineacion> findConfirmadasByPartidoId(@Param("partidoId") Long partidoId);
}