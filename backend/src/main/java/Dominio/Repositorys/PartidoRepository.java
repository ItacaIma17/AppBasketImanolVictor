package Dominio.Repositorys;

import Dominio.Entity.EstadoPartido.EstadoPartido;
import Dominio.Entity.Partido;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface PartidoRepository extends JpaRepository<Partido, Long> {

    Partido countByEstado(EstadoPartido estadoPartido);

    List<Partido> findByFechaBetween(LocalDate inicio, LocalDate fin);
}
