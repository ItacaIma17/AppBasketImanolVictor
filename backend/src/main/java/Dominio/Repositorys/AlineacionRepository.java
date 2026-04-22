package Dominio.Repositorys;


import Dominio.Entity.Alineacion;
import Dominio.Entity.Equipo;
import Dominio.Entity.Partido;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AlineacionRepository extends JpaRepository<Alineacion, Long> {
    Optional<Alineacion> findByPartidoAndEquipo(Partido partido, Equipo equipo);
    boolean existsByPartidoAndEquipo(Partido partido, Equipo equipo);
}
