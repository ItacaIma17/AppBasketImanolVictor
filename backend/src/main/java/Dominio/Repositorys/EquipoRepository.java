package Dominio.Repositorys;

import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EquipoRepository extends JpaRepository<Equipo, Long> {
    boolean existsByNombre(String nombre);
    List<Equipo> findByLiga(Liga liga);
    List<Equipo> findByLigaId(Long ligaId);
}