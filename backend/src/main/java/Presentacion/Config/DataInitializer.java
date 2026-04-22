// Aplicacion/Config/DataInitializer.java
package Presentacion.Config;

import Dominio.Entity.Usuario;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        crearUsuarioAdminSiNoExiste();
    }

    private void crearUsuarioAdminSiNoExiste() {
        // Verificar si ya existe un usuario admin
        if (userRepository.existsByUsername("admin")) {
            log.info("✅ Usuario administrador ya existe");
            return;
        }

        // Crear usuario administrador por defecto
        Usuario admin = new Usuario();
        admin.setUsername("admin");
        admin.setEmail("admin@federacion.com");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setNombre("Administrador");
        admin.setApellido("Sistema");
        admin.setEdad(30);
        admin.setRole(Roles.ADMIN);
        admin.setVerificado(true);  // Admin ya verificado
        admin.setBloqueado(false);

        userRepository.save(admin);

        log.info("========================================");
        log.info("✅ USUARIO ADMINISTRADOR CREADO");
        log.info("📧 Usuario: admin");
        log.info("🔑 Contraseña: admin123");
        log.info("========================================");
    }
}