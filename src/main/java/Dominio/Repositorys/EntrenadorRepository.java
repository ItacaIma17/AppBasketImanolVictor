package Dominio.Repositorys;

import Dominio.Entity.Entrenador;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EntrenadorRepository extends JpaRepository<Entrenador, Long> {
    boolean existsByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByCodigoEntrenador(String codigo);
    Optional<Entrenador> findByEmail(String email);
    Optional<Entrenador> findByUsername(String username);
    Optional<Entrenador> findByCodigoEntrenador(String codigo);
}