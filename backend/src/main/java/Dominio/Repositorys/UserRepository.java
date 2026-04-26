package Dominio.Repositorys;

import Dominio.Entity.Roles.Roles;
import Dominio.Entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<Usuario, Long> {

    // Búsquedas por campos únicos (deberían devolver Optional)
    Usuario findByEmail(String email);
    Usuario findByUsername(String username);

    // Búsqueda combinada
    Optional<Usuario> findByEmailOrUsername(String email, String username);

    // Verificaciones de existencia
    boolean existsByEmail(String email);
    boolean existsByUsername(String username);

    // Búsquedas que pueden devolver múltiples resultados (usar List)
    List<Usuario> findByRole(Roles role);
    List<Usuario> findByVerificado(boolean verificado);
    List<Usuario> findByBloqueado(boolean bloqueado);

    // Búsqueda de un solo administrador (útil para DataLoader)
    Optional<Usuario> findFirstByRole(Roles role);

    // Contadores
    long countByBloqueado(boolean bloqueado);
    long countByVerificado(boolean verificado);

    // Últimos registros
    List<Usuario> findTop5ByOrderByIdDesc();

    // Consultas personalizadas
    @Query("SELECT u FROM Usuario u WHERE u.role = :role AND u.verificado = true")
    List<Usuario> findVerificadosByRole(@Param("role") Roles role);

    @Query("SELECT u FROM Usuario u WHERE u.role = :role AND u.bloqueado = false")
    List<Usuario> findActivosByRole(@Param("role") Roles role);

    // Verificar si existe algún administrador
    @Query("SELECT COUNT(u) > 0 FROM Usuario u WHERE u.role = :role")
    boolean existsByRole(@Param("role") Roles role);
}