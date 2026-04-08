package Dominio.Repositorys;

import Dominio.Entity.Roles.Roles;
import Dominio.Entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<Usuario, Long> {
    boolean existsByEmail(String email);
    boolean existsByUsername(String username);
    Usuario findByEmail(String email);
    Usuario findByUsername(String username);
    Optional<Usuario> findByEmailOrUsername(String email, String username);
    List<Usuario> findByRole(Roles role);
    List<Usuario> findByVerificado(boolean verificado);
    List<Usuario> findByBloqueado(boolean bloqueado);
    long countByBloqueado(boolean bloqueado);
    long countByVerificado(boolean verificado);
    List<Usuario> findTop5ByOrderByIdDesc();
}