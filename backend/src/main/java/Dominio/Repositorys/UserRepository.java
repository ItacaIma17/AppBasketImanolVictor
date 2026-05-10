package Dominio.Repositorys;

import Dominio.Entity.Roles.Roles;
import Dominio.Entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<Usuario, Long> {

    Usuario findByEmail(String email);
    Usuario findByUsername(String username);

    Optional<Usuario> findByEmailOrUsername(String email, String username);

    boolean existsByEmail(String email);
    boolean existsByUsername(String username);

    List<Usuario> findByRole(Roles role);
    List<Usuario> findByVerificado(boolean verificado);
    List<Usuario> findByBloqueado(boolean bloqueado);

    Optional<Usuario> findFirstByRole(Roles role);

    long countByBloqueado(boolean bloqueado);
    long countByVerificado(boolean verificado);

    List<Usuario> findTop5ByOrderByIdDesc();

    @Query("SELECT u FROM Usuario u WHERE u.role = :role AND u.verificado = true")
    List<Usuario> findVerificadosByRole(@Param("role") Roles role);

    @Query("SELECT u FROM Usuario u WHERE u.role = :role AND u.bloqueado = false")
    List<Usuario> findActivosByRole(@Param("role") Roles role);

    @Query("SELECT COUNT(u) > 0 FROM Usuario u WHERE u.role = :role")
    boolean existsByRole(@Param("role") Roles role);

}
