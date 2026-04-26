// Dominio/Repositorys/EntrenadorRepository.java
package Dominio.Repositorys;

import Dominio.Entity.Entrenador;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface EntrenadorRepository extends JpaRepository<Entrenador, Long> {

    Optional<Entrenador> findByUsername(String username);

    Optional<Entrenador> findByEmail(String email);

    Optional<Entrenador> findByCodigoEntrenador(String codigoEntrenador);

    List<Entrenador> findByRole(String role);

    @Query("SELECT e FROM Entrenador e WHERE e.equipo IS NULL")
    List<Entrenador> findEntrenadoresSinEquipo();

    @Query("SELECT e FROM Entrenador e WHERE e.equipo IS NOT NULL")
    List<Entrenador> findEntrenadoresConEquipo();

    @Query("SELECT e FROM Entrenador e WHERE e.verificado = :verificado")
    List<Entrenador> findByVerificado(@Param("verificado") boolean verificado);

    boolean existsByCodigoEntrenador(String codigoEntrenador);

    boolean existsByEmail(String email);

    boolean existsByUsername(String username);

    @Query("SELECT e FROM Entrenador e WHERE e.nombre LIKE %:nombre% OR e.apellido LIKE %:nombre%")
    List<Entrenador> searchByNombre(@Param("nombre") String nombre);

    @Query("SELECT e FROM Entrenador e WHERE e.usuario.id = :usuarioId")
    Optional<Entrenador> findByUsuarioId(@Param("usuarioId") Long usuarioId);


}