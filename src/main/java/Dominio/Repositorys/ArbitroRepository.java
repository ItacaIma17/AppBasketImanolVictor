package Dominio.Repositorys;

import Dominio.Entity.Arbitro;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface ArbitroRepository extends JpaRepository<Arbitro, Long> {
    boolean existsByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByCodigoArbitro(String codigoArbitro);
    Optional<Arbitro> findByEmail(String email);
    Optional<Arbitro> findByUsername(String username);
    Optional<Arbitro> findByCodigoArbitro(String codigoArbitro);
}