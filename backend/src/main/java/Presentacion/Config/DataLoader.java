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
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

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
    private final ActaPartidoRepository actaRepository;
    private final EventoPartidoRepository eventoPartidoRepository;
    private final PasswordEncoder passwordEncoder;

    private static final SecureRandom random = new SecureRandom();

    @Override
    public void run(String... args) {
        log.info("========================================");
        log.info("🚀 Inicializando datos de prueba...");

        // 1. ADMINISTRADOR
        crearAdministrador();

        // 2. LIGAS (3 ligas diferentes)
        crearLigas();

        // 3. EQUIPOS (múltiples equipos por liga)
        crearEquipos();

        // 4. ENTRENADORES
        crearEntrenadores();

        // 5. JUGADORES (con estadísticas)
        crearJugadores();

        // 6. ÁRBITROS
        crearArbitros();

        // 7. ASIGNAR ENTRENADORES A EQUIPOS
        asignarEntrenadoresAEquipos();

        // 8. PARTIDOS
        crearPartidos();

        // 9. ACTAS Y ESTADÍSTICAS
        crearActasYEstadisticas();

        log.info("✅ Inicialización completada");
        log.info("========================================");
        log.info("🔐 CREDENCIALES DE PRUEBA:");
        log.info("   Admin:     admin / Admin123456");
        log.info("   Entrenador: entrenador / Entrenador123");
        log.info("   Árbitro:   arbitro / Arbitro123");
        log.info("   Jugador:   luka.doncic / Jugador123");
        log.info("   Jugador:   rudy.fernandez / Jugador123");
        log.info("========================================");
    }

    // ============================================================
    // ADMINISTRADOR
    // ============================================================
    private void crearAdministrador() {
        if (userRepository.existsByUsername("admin")) return;

        Usuario admin = new Usuario();
        admin.setUsername("admin");
        admin.setEmail("admin@admin.com");
        admin.setPassword(passwordEncoder.encode("Admin123456"));
        admin.setNombre("Administrador");
        admin.setApellido("Sistema");
        admin.setEdad(30);
        admin.setRole(Roles.ADMIN);
        admin.setVerificado(true);
        admin.setBloqueado(false);
        userRepository.save(admin);
        log.info("✅ Administrador creado");
    }

    // ============================================================
    // LIGAS (3 ligas)
    // ============================================================
    private void crearLigas() {
        crearLiga("Liga ACB", "España", 18, "2024-2025");
        crearLiga("Liga EBA", "España", 16, "2024-2025");
        crearLiga("Euroliga", "Europa", 18, "2024-2025");
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
    // EQUIPOS POR LIGA
    // ============================================================
    private void crearEquipos() {
        Liga acb = ligaRepository.findByNombreLiga("Liga ACB").orElse(null);
        Liga eba = ligaRepository.findByNombreLiga("Liga EBA").orElse(null);
        Liga euroliga = ligaRepository.findByNombreLiga("Euroliga").orElse(null);

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
        crearEquipo("Teruel Basket", "Teruel", "Pabellón de Deportes", 1995, eba);

        // Equipos Euroliga
        crearEquipo("Panathinaikos", "Atenas", "OAKA", 1922, euroliga);
        crearEquipo("Olympiacos", "El Pireo", "Peace and Friendship", 1925, euroliga);
        crearEquipo("Fenerbahçe", "Estambul", "Ülker Arena", 1913, euroliga);
        crearEquipo("Anadolu Efes", "Estambul", "Sinan Erdem Dome", 1976, euroliga);
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
    // ENTRENADORES
    // ============================================================
    private void crearEntrenadores() {
        crearEntrenador("entrenador", "entrenador@test.com", "Carlos", "López", 45, "ENT-100001");
        crearEntrenador("entrenador2", "entrenador2@test.com", "Juan", "Martínez", 50, "ENT-100002");
        crearEntrenador("entrenador3", "entrenador3@test.com", "Pablo", "García", 38, "ENT-100003");
        crearEntrenador("entrenador4", "entrenador4@test.com", "Miguel", "Fernández", 42, "ENT-100004");
    }

    private void crearEntrenador(String username, String email, String nombre, String apellido, int edad, String codigo) {
        if (entrenadorRepository.findByUsername(username).isPresent()) return;

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
        entrenadorRepository.save(entrenador);
        log.info("✅ Entrenador creado: {}", username);
    }

    // ============================================================
    // JUGADORES CON ESTADÍSTICAS
    // ============================================================
    private void crearJugadores() {
        Equipo realMadrid = equipoRepository.findByNombre("Real Madrid").orElse(null);
        Equipo barcelona = equipoRepository.findByNombre("FC Barcelona").orElse(null);
        Equipo unicaja = equipoRepository.findByNombre("Unicaja").orElse(null);
        Equipo baskonia = equipoRepository.findByNombre("Baskonia").orElse(null);
        Equipo valencia = equipoRepository.findByNombre("Valencia Basket").orElse(null);
        Equipo joventut = equipoRepository.findByNombre("Joventut").orElse(null);

        // Real Madrid - Jugadores con altas estadísticas
        crearJugadorConEstadisticas("luka.doncic", "luka.doncic@test.com", "Luka", "Doncic", 25,
                "Base", 7, 2.01, 104, realMadrid, "JUG-001", 28.5, 8.2, 7.5, 1.2);
        crearJugadorConEstadisticas("rudy.fernandez", "rudy.fernandez@test.com", "Rudy", "Fernández", 38,
                "Escolta", 5, 1.96, 85, realMadrid, "JUG-002", 12.3, 4.1, 2.8, 0.9);
        crearJugadorConEstadisticas("sergio.llull", "sergio.llull@test.com", "Sergio", "Llull", 36,
                "Base", 9, 1.90, 85, realMadrid, "JUG-003", 14.2, 3.5, 5.1, 0.8);
        crearJugadorConEstadisticas("edgar.vives", "edgar.vives@test.com", "Edgar", "Vives", 30,
                "Base", 1, 1.84, 75, realMadrid, "JUG-004", 8.5, 2.1, 4.2, 1.0);
        crearJugadorConEstadisticas("alberto.abalde", "alberto.abalde@test.com", "Alberto", "Abalde", 28,
                "Alero", 6, 2.02, 95, realMadrid, "JUG-005", 11.2, 4.8, 3.1, 0.7);

        // FC Barcelona
        crearJugadorConEstadisticas("ricky.rubio", "ricky.rubio@test.com", "Ricky", "Rubio", 33,
                "Base", 3, 1.88, 82, barcelona, "JUG-006", 9.8, 3.2, 6.8, 1.5);
        crearJugadorConEstadisticas("niko.mirotic", "niko.mirotic@test.com", "Niko", "Mirotic", 33,
                "Ala-Pívot", 33, 2.08, 110, barcelona, "JUG-007", 18.5, 7.2, 1.5, 0.8);
        crearJugadorConEstadisticas("alex.abrines", "alex.abrines@test.com", "Alex", "Abrines", 30,
                "Escolta", 8, 1.98, 90, barcelona, "JUG-008", 15.2, 3.5, 1.2, 0.9);

        // Unicaja
        crearJugadorConEstadisticas("dario.brizuela", "dario.brizuela@test.com", "Dario", "Brizuela", 28,
                "Escolta", 8, 1.88, 80, unicaja, "JUG-009", 16.5, 3.2, 2.5, 1.1);
        crearJugadorConEstadisticas("kendrick.perry", "kendrick.perry@test.com", "Kendrick", "Perry", 32,
                "Base", 1, 1.83, 78, unicaja, "JUG-010", 14.8, 2.5, 5.5, 1.3);

        // Baskonia
        crearJugadorConEstadisticas("markus.howard", "markus.howard@test.com", "Markus", "Howard", 25,
                "Base", 11, 1.78, 75, baskonia, "JUG-011", 22.5, 2.8, 4.2, 1.1);

        // Valencia
        crearJugadorConEstadisticas("damien.inglis", "damien.inglis@test.com", "Damien", "Inglis", 29,
                "Ala-Pívot", 5, 2.03, 98, valencia, "JUG-012", 12.5, 6.5, 2.2, 0.6);

        // Joventut
        crearJugadorConEstadisticas("antonia.dawson", "antonia.dawson@test.com", "Antonia", "Dawson", 31,
                "Alero", 20, 1.98, 95, joventut, "JUG-013", 15.8, 5.5, 1.8, 1.2);
    }

    private void crearJugadorConEstadisticas(String username, String email, String nombre, String apellido, int edad,
                                             String posicion, int dorsal, double altura, double peso, Equipo equipo, String codigo,
                                             double puntos, double rebotes, double asistencias, double robos) {

        if (userRepository.existsByUsername(username)) return;

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

        log.info("✅ Jugador creado: {} {} - Pts: {}, Reb: {}, Ast: {}",
                nombre, apellido, puntos, rebotes, asistencias);
    }

    // ============================================================
    // ÁRBITROS
    // ============================================================
    private void crearArbitros() {
        crearArbitro("arbitro", "arbitro@test.com", "Juan", "García", 45, "ARB-100001");
        crearArbitro("arbitro2", "arbitro2@test.com", "Pedro", "Martínez", 50, "ARB-100002");
        crearArbitro("arbitro3", "arbitro3@test.com", "Luis", "Sánchez", 38, "ARB-100003");
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
        log.info("✅ Árbitro creado: {}", username);
    }

    // ============================================================
    // ASIGNAR ENTRENADORES A EQUIPOS
    // ============================================================
    private void asignarEntrenadoresAEquipos() {
        Equipo real = equipoRepository.findByNombre("Real Madrid").orElse(null);
        Equipo barca = equipoRepository.findByNombre("FC Barcelona").orElse(null);
        Equipo unicaja = equipoRepository.findByNombre("Unicaja").orElse(null);
        Equipo baskonia = equipoRepository.findByNombre("Baskonia").orElse(null);
        Equipo valencia = equipoRepository.findByNombre("Valencia Basket").orElse(null);
        Equipo joventut = equipoRepository.findByNombre("Joventut").orElse(null);

        Entrenador entrenador1 = entrenadorRepository.findByUsername("entrenador").orElse(null);
        Entrenador entrenador2 = entrenadorRepository.findByUsername("entrenador2").orElse(null);
        Entrenador entrenador3 = entrenadorRepository.findByUsername("entrenador3").orElse(null);
        Entrenador entrenador4 = entrenadorRepository.findByUsername("entrenador4").orElse(null);

        asignarEntrenadorAEquipo(entrenador1, real);
        asignarEntrenadorAEquipo(entrenador2, barca);
        asignarEntrenadorAEquipo(entrenador3, unicaja);
        asignarEntrenadorAEquipo(entrenador4, baskonia);
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
        Arbitro arbitro3 = arbitroRepository.findByUsername("arbitro3").orElse(null);

        LocalDateTime now = LocalDateTime.now();

        // Partidos ACB
        crearPartido(real, barca, now.minusDays(14), "WiZink Center", arbitro1);
        crearPartido(barca, real, now.minusDays(7), "Palau Blaugrana", arbitro2);
        crearPartido(real, unicaja, now.plusDays(7), "WiZink Center", arbitro1);
        crearPartido(barca, baskonia, now.plusDays(14), "Palau Blaugrana", arbitro2);
        crearPartido(valencia, joventut, now.plusDays(21), "Fuente de San Luis", arbitro3);
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
    // ACTAS Y ESTADÍSTICAS
    // ============================================================
    // En DataLoader.java - método crearActasYEstadisticas()

    private void crearActasYEstadisticas() {
        List<Partido> partidosReal = partidoRepository.findByEquipoLocalIdOrEquipoVisitanteId(1L);

        // Buscar el partido contra Barcelona (ID 2)
        Partido partidoRealBarça = partidosReal.stream()
                .filter(p -> p.getEquipoLocal().getId() == 2L || p.getEquipoVisitante().getId() == 2L)
                .findFirst()
                .orElse(null);

        if (partidoRealBarça != null && partidoRealBarça.getActa() == null) {


                Arbitro arbitro = partidoRealBarça.getArbitro();

                ActaPartido acta = new ActaPartido();
                acta.setPartido(partidoRealBarça);
                acta.setArbitro(arbitro);
                acta.setFechaActa(LocalDateTime.now());
                acta.setResultadoLocal("95");
                acta.setResultadoVisitante("88");
                acta.setObservaciones("Gran partido con mucha intensidad");

                partidoRealBarça.setResultadoLocal(95);
                partidoRealBarça.setResultadoVisitante(88);
                partidoRealBarça.setEstado("FINALIZADO");

                actaRepository.save(acta);
                partidoRepository.save(partidoRealBarça);

                log.info("✅ Acta creada para Real Madrid vs FC Barcelona: 95-88");

        } else {
            log.warn("⚠️ No se encontró el partido Real Madrid vs FC Barcelona");
        }
    }

    // ============================================================
    // UTILIDADES
    // ============================================================
    private String generarCodigoEquipo() {
        return "EQ-" + (100000 + random.nextInt(900000));
    }
}