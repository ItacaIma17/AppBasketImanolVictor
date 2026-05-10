package Dominio.Repositorys;

import Dominio.Entity.Jugador;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface JugadorRepository extends JpaRepository<Jugador, Long> {
    boolean existsByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByCodigoJugador(String codigo);
    Optional<Jugador> findByEmail(String email);
    Optional<Jugador> findByUsername(String username);
    Optional<Jugador> findByCodigoJugador(String codigo);
    List<Jugador> findByEquipoId(Long equipoId);
    List<Jugador> findByEquipoIsNull();
    List<Jugador> findByPosicion(String posicion);
    long countByEquipoId(Long equipoId);

}
