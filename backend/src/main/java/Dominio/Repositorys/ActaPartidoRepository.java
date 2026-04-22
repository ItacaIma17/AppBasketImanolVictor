package Dominio.Repositorys;

import Dominio.Entity.ActaPartido;
import Dominio.Entity.Partido;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ActaPartidoRepository extends JpaRepository<ActaPartido, Long> {
    Optional<ActaPartido> findByPartido(Partido partido);
    boolean existsByPartido(Partido partido);
}
