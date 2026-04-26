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
import java.security.SecureRandom;
import java.time.LocalDateTime;

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
    private final PartidoRepository partidoRepository;
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

    private static final SecureRandom random = new SecureRandom();

    @Override
    public void run(String... args) {
        log.info("========================================");
        log.info("🚀 Inicializando datos de prueba...");

        // 1. ADMINISTRADOR
        crearAdministrador();

        // 2. LIGAS
        crearLigas();

        // 3. EQUIPOS
        crearEquipos();

        // 4. ENTRENADORES (incluyendo el de prueba)
        crearEntrenadores();

        // 5. JUGADORES
        crearJugadores();

        // 6. ÁRBITROS
        crearArbitros();

        // 7. ASIGNAR ENTRENADORES A EQUIPOS
        asignarEntrenadoresAEquipos();

        // 8. PARTIDOS
        crearPartidos();

        log.info("✅ Inicialización completada");
        log.info("========================================");
        log.info("🔐 CREDENCIALES DE PRUEBA:");
        log.info("   Admin:     admin / Admin123456");
        log.info("   Entrenador: entrenador / Entrenador123");
        log.info("   Árbitro:   arbitro / Arbitro123");
        log.info("   Jugador:   luka.doncic / Jugador123");
        log.info("========================================");
    }

    // ============================================================
    // ADMINISTRADOR
    // ============================================================
    private void crearAdministrador() {
        if (userRepository.existsByUsername(adminUsername)) {
            log.info("👑 Administrador ya existe: {}", adminUsername);
            return;
        }
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
        log.info("✅ Administrador creado: {} / {}", adminUsername, adminPassword);
    }

    // ============================================================
    // LIGAS
    // ============================================================
    private void crearLigas() {
        crearLiga("Liga ACB", "España", 18, "2024-2025");
        crearLiga("Liga EBA", "España", 16, "2024-2025");
        crearLiga("Euroliga", "Europa", 18, "2024-2025");
        crearLiga("Liga Catalana", "España", 8, "2024-2025");
        crearLiga("Liga Vasca", "España", 6, "2024-2025");
    }

    private void crearLiga(String nombre, String pais, int numEquipos, String temporada) {
        if (!ligaRepository.existsByNombreLiga(nombre)) {
            Liga liga = new Liga();
            liga.setNombreLiga(nombre);
            liga.setPais(pais);
            liga.setNumeroEquipos(numEquipos);
            liga.setTemporada(temporada);
            ligaRepository.save(liga);
            log.info("✅ Liga creada: {}", nombre);
        }
    }

    // ============================================================
    // EQUIPOS
    // ============================================================
    private void crearEquipos() {
        Liga acb = ligaRepository.findByNombreLiga("Liga ACB").orElse(null);
        Liga eba = ligaRepository.findByNombreLiga("Liga EBA").orElse(null);

        // Equipos ACB
        crearEquipo("Real Madrid", "Madrid", "WiZink Center", 1931, acb);
        crearEquipo("FC Barcelona", "Barcelona", "Palau Blaugrana", 1926, acb);
        crearEquipo("Unicaja", "Málaga", "Martín Carpena", 1992, acb);
        crearEquipo("Baskonia", "Vitoria", "Buesa Arena", 1959, acb);
        crearEquipo("Valencia Basket", "Valencia", "Fuente de San Luis", 1986, acb);
        crearEquipo("Joventut", "Badalona", "Palau Olímpic", 1930, acb);

        // Equipos EBA
        crearEquipo("Tarazona Basket", "Tarazona", "Pabellón Municipal", 2000, eba);
        crearEquipo("Zaragoza Basket", "Zaragoza", "Príncipe Felipe", 2002, eba);
        crearEquipo("Huesca Basket", "Huesca", "Palacio de Deportes", 1977, eba);
    }

    private void crearEquipo(String nombre, String ciudad, String estadio, int anio, Liga liga) {
        if (!equipoRepository.findByNombre(nombre).isPresent()) {
            Equipo equipo = new Equipo();
            equipo.setNombre(nombre);
            equipo.setCiudad(ciudad);
            equipo.setNombreEstadio(estadio);
            equipo.setAnoFundacion(anio);
            equipo.setLiga(liga);
            equipo.setCodigoSolicitud(generarCodigoEquipo());
            equipo.setSolicitudPendiente(false);
            equipoRepository.save(equipo);
            log.info("✅ Equipo creado: {}", nombre);
        }
    }

    // ============================================================
    // ENTRENADORES (incluye 'entrenador' por defecto)
    // ============================================================
    private void crearEntrenadores() {
        // Entrenador principal (para login con username "entrenador")
        crearEntrenador(
                "entrenador", "entrenador@test.com", "Entrenador", "Principal",
                45, "ENT-100001", "666111222", "10 años experiencia"
        );
        // Otros entrenadores
        crearEntrenador(
                "entrenador2", "entrenador2@test.com", "Carlos", "López",
                50, "ENT-100002", "666222333", "15 años experiencia"
        );
        crearEntrenador(
                "entrenador3", "entrenador3@test.com", "María", "García",
                38, "ENT-100003", "666333444", "8 años experiencia"
        );
    }

    private void crearEntrenador(String username, String email, String nombre, String apellido,
                                 int edad, String codigo, String telefono, String experiencia) {
        if (entrenadorRepository.findByUsername(username).isPresent()) return;

        // Usuario base
        Usuario usuario = new Usuario();
        usuario.setUsername(username);
        usuario.setEmail(email);
        usuario.setPassword(passwordEncoder.encode("Entrenador123"));
        usuario.setNombre(nombre);
        usuario.setApellido(apellido);
        usuario.setEdad(edad);
        usuario.setRole(Roles.ENTRENADOR);
        usuario.setVerificado(true);
        usuario.setBloqueado(false);
        userRepository.save(usuario);

        // Entrenador
        Entrenador entrenador = new Entrenador();
        entrenador.setNombre(nombre);
        entrenador.setApellido(apellido);
        entrenador.setUsername(username);
        entrenador.setPassword(usuario.getPassword());
        entrenador.setEmail(email);
        entrenador.setEdad(edad);
        entrenador.setCodigoEntrenador(codigo);
        entrenador.setRole(Roles.ENTRENADOR);
        entrenador.setVerificado(true);
        entrenador.setUsuario(usuario);
        entrenador.setTelefono(telefono);
        entrenador.setExperiencia(experiencia);
        entrenadorRepository.save(entrenador);
        log.info("✅ Entrenador creado: {} ({})", username, codigo);
    }

    // ============================================================
    // JUGADORES
    // ============================================================
    private void crearJugadores() {
        Equipo realMadrid = equipoRepository.findByNombre("Real Madrid").orElse(null);
        Equipo barcelona = equipoRepository.findByNombre("FC Barcelona").orElse(null);
        Equipo tarazona = equipoRepository.findByNombre("Tarazona Basket").orElse(null);

        // Jugadores Real Madrid
        crearJugador("luka.doncic", "luka.doncic@test.com", "Luka", "Doncic", 25,
                "Base", 7, 2.01, 104, realMadrid, "JUG-001");
        crearJugador("rudy.fernandez", "rudy.fernandez@test.com", "Rudy", "Fernández", 38,
                "Escolta", 5, 1.96, 85, realMadrid, "JUG-002");
        crearJugador("sergio.llull", "sergio.llull@test.com", "Sergio", "Llull", 36,
                "Base", 9, 1.90, 85, realMadrid, "JUG-003");

        // Jugadores Barcelona
        crearJugador("ricky.rubio", "ricky.rubio@test.com", "Ricky", "Rubio", 33,
                "Base", 3, 1.88, 82, barcelona, "JUG-004");
        crearJugador("niko.mirotic", "niko.mirotic@test.com", "Niko", "Mirotic", 33,
                "Ala-Pívot", 33, 2.08, 110, barcelona, "JUG-005");

        // Jugadores Tarazona
        crearJugador("juan.perez", "juan.perez@test.com", "Juan", "Pérez", 25,
                "Base", 4, 1.85, 78, tarazona, "JUG-006");
        crearJugador("carlos.garcia", "carlos.garcia@test.com", "Carlos", "García", 28,
                "Escolta", 7, 1.90, 85, tarazona, "JUG-007");
    }

    private void crearJugador(String username, String email, String nombre, String apellido, int edad,
                              String posicion, int dorsal, double altura, double peso, Equipo equipo, String codigo) {
        if (userRepository.existsByUsername(username)) return;

        // Usuario base
        Usuario usuario = new Usuario();
        usuario.setUsername(username);
        usuario.setEmail(email);
        usuario.setPassword(passwordEncoder.encode("Jugador123"));
        usuario.setNombre(nombre);
        usuario.setApellido(apellido);
        usuario.setEdad(edad);
        usuario.setRole(Roles.JUGADOR);
        usuario.setVerificado(true);
        usuario.setBloqueado(false);
        userRepository.save(usuario);

        // Jugador
        Jugador jugador = new Jugador();
        jugador.setNombre(nombre);
        jugador.setApellido(apellido);
        jugador.setUsername(username);
        jugador.setPassword(usuario.getPassword());
        jugador.setEmail(email);
        jugador.setEdad(edad);
        jugador.setPosicion(posicion);
        jugador.setDorsal(dorsal);
        jugador.setAltura(altura);
        jugador.setPeso(peso);
        jugador.setCodigoJugador(codigo);
        jugador.setRole(Roles.JUGADOR);
        jugador.setVerificado(true);
        jugador.setUsuario(usuario);
        jugador.setEquipo(equipo);
        jugadorRepository.save(jugador);
        log.info("✅ Jugador creado: {} {} ({})", nombre, apellido, username);
    }

    // ============================================================
    // ÁRBITROS
    // ============================================================
    private void crearArbitros() {
        crearArbitro("arbitro", "arbitro@test.com", "Árbitro", "Principal", 45, "ARB-100001");
        crearArbitro("arbitro2", "arbitro2@test.com", "Juan", "Martínez", 50, "ARB-100002");
    }

    private void crearArbitro(String username, String email, String nombre, String apellido, int edad, String codigo) {
        if (arbitroRepository.findByUsername(username).isPresent()) return;

        Usuario usuario = new Usuario();
        usuario.setUsername(username);
        usuario.setEmail(email);
        usuario.setPassword(passwordEncoder.encode("Arbitro123"));
        usuario.setNombre(nombre);
        usuario.setApellido(apellido);
        usuario.setEdad(edad);
        usuario.setRole(Roles.ARBITRO);
        usuario.setVerificado(true);
        usuario.setBloqueado(false);
        userRepository.save(usuario);

        Arbitro arbitro = new Arbitro();
        arbitro.setNombre(nombre);
        arbitro.setApellidos(apellido);
        arbitro.setUsername(username);
        arbitro.setPassword(usuario.getPassword());
        arbitro.setEmail(email);
        arbitro.setEdad(edad);
        arbitro.setCodigoArbitro(codigo);
        arbitro.setRole(Roles.ARBITRO);
        arbitro.setVerificado(true);
        arbitro.setUsuario(usuario);
        arbitroRepository.save(arbitro);
        log.info("✅ Árbitro creado: {} ({})", username, codigo);
    }

    // ============================================================
    // ASIGNAR ENTRENADORES A EQUIPOS
    // ============================================================
    private void asignarEntrenadoresAEquipos() {
        Equipo real = equipoRepository.findByNombre("Real Madrid").orElse(null);
        Equipo barca = equipoRepository.findByNombre("FC Barcelona").orElse(null);
        Equipo tarazona = equipoRepository.findByNombre("Tarazona Basket").orElse(null);

        Entrenador entrenador1 = entrenadorRepository.findByUsername("entrenador").orElse(null);
        Entrenador entrenador2 = entrenadorRepository.findByUsername("entrenador2").orElse(null);
        Entrenador entrenador3 = entrenadorRepository.findByUsername("entrenador3").orElse(null);

        asignarEntrenadorAEquipo(entrenador1, real);
        asignarEntrenadorAEquipo(entrenador2, barca);
        asignarEntrenadorAEquipo(entrenador3, tarazona);
    }

    private void asignarEntrenadorAEquipo(Entrenador entrenador, Equipo equipo) {
        if (entrenador != null && equipo != null && entrenador.getEquipo() == null) {
            entrenador.setEquipo(equipo);
            equipo.setEntrenador(entrenador);
            entrenadorRepository.save(entrenador);
            equipoRepository.save(equipo);
            log.info("✅ Entrenador {} asignado a {}", entrenador.getUsername(), equipo.getNombre());
        }
    }

    // ============================================================
    // PARTIDOS
    // ============================================================
    private void crearPartidos() {
        Equipo real = equipoRepository.findByNombre("Real Madrid").orElse(null);
        Equipo barca = equipoRepository.findByNombre("FC Barcelona").orElse(null);
        Equipo unicaja = equipoRepository.findByNombre("Unicaja").orElse(null);
        Equipo baskonia = equipoRepository.findByNombre("Baskonia").orElse(null);
        Equipo valencia = equipoRepository.findByNombre("Valencia Basket").orElse(null);
        Equipo joventut = equipoRepository.findByNombre("Joventut").orElse(null);

        Arbitro arbitro1 = arbitroRepository.findByUsername("arbitro").orElse(null);
        Arbitro arbitro2 = arbitroRepository.findByUsername("arbitro2").orElse(null);

        LocalDateTime now = LocalDateTime.now();

        crearPartido(real, barca, now.plusDays(7), "WiZink Center", arbitro1);
        crearPartido(barca, real, now.plusDays(14), "Palau Blaugrana", arbitro2);
        crearPartido(real, unicaja, now.plusDays(21), "WiZink Center", arbitro1);
        crearPartido(barca, baskonia, now.plusDays(28), "Palau Blaugrana", arbitro2);
        crearPartido(valencia, joventut, now.plusDays(35), "Fuente de San Luis", arbitro1);
    }

    private void crearPartido(Equipo local, Equipo visitante, LocalDateTime fecha, String ubicacion, Arbitro arbitro) {
        if (local == null || visitante == null) return;
        if (partidoRepository.existsPartidoEntreEquipos(local.getId(), visitante.getId())) return;

        Partido partido = new Partido();
        partido.setEquipoLocal(local);
        partido.setEquipoVisitante(visitante);
        partido.setFecha(fecha);
        partido.setUbicacion(ubicacion);
        partido.setEstado("PROGRAMADO");
        partido.setArbitro(arbitro);
        partido.setLiga(local.getLiga());
        partidoRepository.save(partido);
        log.info("✅ Partido creado: {} vs {} - {}", local.getNombre(), visitante.getNombre(), fecha);
    }

    // ============================================================
    // UTILIDADES
    // ============================================================
    private String generarCodigoEquipo() {
        return "EQ-" + (100000 + random.nextInt(900000));
    }
}