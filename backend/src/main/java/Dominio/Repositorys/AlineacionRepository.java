package Dominio.Repositorys;

import Dominio.Entity.Alineacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface AlineacionRepository extends JpaRepository<Alineacion, Long> {

    Optional<Alineacion> findByPartidoIdAndEquipoId(Long partidoId, Long equipoId);
}
