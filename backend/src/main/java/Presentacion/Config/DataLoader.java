// Aplicacion/Config/DataLoader.java
package Presentacion.Config;

import Dominio.Entity.*;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataLoader implements CommandLineRunner {

    private final UserRepository userRepository;
    private final EntrenadorRepository entrenadorRepository;
    private final ArbitroRepository arbitroRepository;
    private final JugadorRepository jugadorRepository;
    private final EquipoRepository equipoRepository;
    private final LigaRepository ligaRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${admin.username:admin}")
    private String adminUsername;

    @Value("${admin.email:admin@admin.com}")
    private String adminEmail;

    @Value("${admin.password:Admin123456}")
    private String adminPassword;

    @Value("${admin.nombre:Administrador}")
    private String adminNombre;

    @Value("${admin.apellido:Sistema}")
    private String adminApellido;

    // Configuración de usuarios por defecto
    private static final String DEFAULT_ENTRENADOR_USERNAME = "entrenador";
    private static final String DEFAULT_ENTRENADOR_EMAIL = "entrenador@test.com";
    private static final String DEFAULT_ENTRENADOR_PASSWORD = "Entrenador123";
    private static final String DEFAULT_ENTRENADOR_CODIGO = "ENT-100001";

    private static final String DEFAULT_ARBITRO_USERNAME = "arbitro";
    private static final String DEFAULT_ARBITRO_EMAIL = "arbitro@test.com";
    private static final String DEFAULT_ARBITRO_PASSWORD = "Arbitro123";
    private static final String DEFAULT_ARBITRO_CODIGO = "ARB-100001";

    private static final String DEFAULT_JUGADOR_USERNAME = "jugador";
    private static final String DEFAULT_JUGADOR_EMAIL = "jugador@test.com";
    private static final String DEFAULT_JUGADOR_PASSWORD = "Jugador123";
    private static final String DEFAULT_JUGADOR_CODIGO = "JUG-100001";

    @Override
    public void run(String... args) {
        log.info("========================================");
        log.info("🚀 Inicializando datos de la aplicación...");

        // Crear usuario administrador
        crearUsuarioAdministrador();

        // Crear usuarios por defecto
        crearUsuarioPorDefecto(
                DEFAULT_ENTRENADOR_USERNAME,
                DEFAULT_ENTRENADOR_EMAIL,
                DEFAULT_ENTRENADOR_PASSWORD,
                "Entrenador",
                "Defecto",
                30,
                Roles.ENTRENADOR,
                DEFAULT_ENTRENADOR_CODIGO
        );

        crearUsuarioPorDefecto(
                DEFAULT_ARBITRO_USERNAME,
                DEFAULT_ARBITRO_EMAIL,
                DEFAULT_ARBITRO_PASSWORD,
                "Árbitro",
                "Defecto",
                35,
                Roles.ARBITRO,
                DEFAULT_ARBITRO_CODIGO
        );

        crearUsuarioPorDefecto(
                DEFAULT_JUGADOR_USERNAME,
                DEFAULT_JUGADOR_EMAIL,
                DEFAULT_JUGADOR_PASSWORD,
                "Jugador",
                "Defecto",
                25,
                Roles.JUGADOR,
                DEFAULT_JUGADOR_CODIGO
        );

        log.info("✅ Inicialización completada");
        log.info("========================================");
    }

    private void crearUsuarioAdministrador() {
        if (userRepository.existsByUsername(adminUsername)) {
            log.info("👑 Administrador ya existe: {}", adminUsername);
            return;
        }

        log.info("👑 Creando administrador por defecto...");

        Usuario admin = new Usuario();
        admin.setUsername(adminUsername);
        admin.setEmail(adminEmail);
        admin.setPassword(passwordEncoder.encode(adminPassword));
        admin.setNombre(adminNombre);
        admin.setApellido(adminApellido);
        admin.setEdad(30);
        admin.setRole(Roles.ADMIN);
        admin.setVerificado(true);
        admin.setBloqueado(false);

        userRepository.save(admin);

        log.info("✅ Administrador creado:");
        log.info("   Usuario: {}", adminUsername);
        log.info("   Password: {}", adminPassword);
        log.info("   Email: {}", adminEmail);
    }

    private void crearUsuarioPorDefecto(
            String username, String email, String password,
            String nombre, String apellido, int edad,
            Roles rol, String codigo) {

        // Verificar si el usuario ya existe
        if (userRepository.existsByUsername(username)) {
            log.info("👤 Usuario {} ya existe", username);
            return;
        }

        log.info("👤 Creando usuario {} por defecto...", username);

        // Crear usuario base
        Usuario usuario = new Usuario();
        usuario.setUsername(username);
        usuario.setEmail(email);
        usuario.setPassword(passwordEncoder.encode(password));
        usuario.setNombre(nombre);
        usuario.setApellido(apellido);
        usuario.setEdad(edad);
        usuario.setRole(rol);
        usuario.setVerificado(true);
        usuario.setBloqueado(false);

        userRepository.save(usuario);

        // Crear entidad específica según el rol
        switch (rol) {
            case ENTRENADOR:
                crearEntrenadorPorDefecto(usuario, codigo);
                break;
            case ARBITRO:
                crearArbitroPorDefecto(usuario, codigo);
                break;
            case JUGADOR:
                crearJugadorPorDefecto(usuario, codigo);
                break;
            default:
                break;
        }

        log.info("✅ Usuario {} creado:", username);
        log.info("   Password: {}", password);
        log.info("   Email: {}", email);
        log.info("   Rol: {}", rol);
    }

    private void crearEntrenadorPorDefecto(Usuario usuario, String codigo) {
        Entrenador entrenador = new Entrenador();
        entrenador.setNombre(usuario.getNombre());
        entrenador.setApellido(usuario.getApellido());
        entrenador.setUsername(usuario.getUsername());
        entrenador.setPassword(usuario.getPassword());
        entrenador.setEmail(usuario.getEmail());
        entrenador.setEdad(usuario.getEdad());
        entrenador.setCodigoEntrenador(codigo);
        entrenador.setRole(Roles.ENTRENADOR);
        entrenador.setVerificado(true);
        entrenador.setUsuario(usuario);

        entrenadorRepository.save(entrenador);
        log.info("   Código entrenador: {}", codigo);
    }

    private void crearArbitroPorDefecto(Usuario usuario, String codigo) {
        Arbitro arbitro = new Arbitro();
        arbitro.setNombre(usuario.getNombre());
        arbitro.setApellidos(usuario.getApellido());
        arbitro.setUsername(usuario.getUsername());
        arbitro.setPassword(usuario.getPassword());
        arbitro.setEmail(usuario.getEmail());
        arbitro.setEdad(usuario.getEdad());
        arbitro.setCodigoArbitro(codigo);
        arbitro.setRole(Roles.ARBITRO);
        arbitro.setVerificado(true);
        arbitro.setUsuario(usuario);

        arbitroRepository.save(arbitro);
        log.info("   Código árbitro: {}", codigo);
    }

    private void crearJugadorPorDefecto(Usuario usuario, String codigo) {
        Jugador jugador = new Jugador();
        jugador.setNombre(usuario.getNombre());
        jugador.setApellido(usuario.getApellido());
        jugador.setUsername(usuario.getUsername());
        jugador.setPassword(usuario.getPassword());
        jugador.setEmail(usuario.getEmail());
        jugador.setEdad(usuario.getEdad());
        jugador.setCodigoJugador(codigo);
        jugador.setPosicion("Base");
        jugador.setDorsal(10);
        jugador.setAltura(1.85);
        jugador.setPeso(80.0);
        jugador.setRole(Roles.JUGADOR);
        jugador.setVerificado(true);
        jugador.setUsuario(usuario);

        jugadorRepository.save(jugador);
        log.info("   Código jugador: {}", codigo);
    }
}