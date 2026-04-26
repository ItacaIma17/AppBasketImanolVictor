package Dominio.Repositorys;

import Dominio.Entity.Partido;
import Dominio.Entity.EstadoPartido.EstadoPartido;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface PartidoRepository extends JpaRepository<Partido, Long> {

    Partido countByEstado(EstadoPartido estadoPartido);

    List<Partido> findByFechaBetween(LocalDate inicio, LocalDate fin);

    List<Partido> findByEquipoLocalId(Long id);

    List<Partido> findByEquipoVisitanteId(Long id);

    List<Partido> findByLigaId(Long id);
}
