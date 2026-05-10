package Aplicacion.Services;

import Dominio.Entity.Equipo;
import Dominio.Entity.Jugador;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.JugadorRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Jugador.JugadorRequest;
import Presentacion.DTOS.Jugador.JugadorResponse;
import Presentacion.DTOS.Usuarios.Register.RegistroJugadorDTO;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class JugadorService {

    private final JugadorRepository jugadorRepository;
    private final EquipoRepository equipoRepository;
    private final PartidoRepository partidoRepository;
    private final PasswordEncoder passwordEncoder;

    private static final SecureRandom random = new SecureRandom();

    @Transactional
    public void crearDesdeRegistro(RegistroJugadorDTO dto,
                                   Dominio.Entity.Usuario usuario) {
        validarCodigoJugador(dto.getCodigoJugador());

        if (jugadorRepository.existsByEmail(dto.getEmail()))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un jugador con este email");
        if (jugadorRepository.existsByUsername(dto.getUsername()))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un jugador con este username");

        Equipo equipo = null;
        if (dto.getEquipoId() != null) {
            equipo = equipoRepository.findById(dto.getEquipoId())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Equipo no encontrado"));
        }

        Jugador jugador = new Jugador();
        jugador.setNombre(dto.getNombre());
        jugador.setApellido(dto.getApellido());
        jugador.setUsername(dto.getUsername());
        jugador.setEmail(dto.getEmail());
        jugador.setPassword(usuario.getPassword());
        jugador.setEdad(dto.getEdad());
        jugador.setAltura(dto.getAltura());
        jugador.setPeso(dto.getPeso());
        jugador.setPosicion(dto.getPosicion());
        jugador.setDorsal(dto.getDorsal());
        jugador.setCodigoJugador(dto.getCodigoJugador());
        jugador.setRole(dto.getRol());
        jugador.setEquipo(equipo);
        jugador.setVerificado(false);

        jugador.setPuntosTotales(0);
        jugador.setRebotesTotales(0);
        jugador.setAsistenciasTotales(0);
        jugador.setRobosTotales(0);
        jugador.setPartidosJugados(0);

        jugadorRepository.save(jugador);
        log.info("Jugador creado: {}", jugador.getEmail());
    }

    @Transactional
    public void marcarComoVerificado(String email) {
        jugadorRepository.findByEmail(email).ifPresent(j -> {
            j.setVerificado(true);
            jugadorRepository.save(j);
        });
    }

    @Transactional
    public void actualizarPassword(String email, String passwordEncriptada) {
        jugadorRepository.findByEmail(email).ifPresent(j -> {
            j.setPassword(passwordEncriptada);
            jugadorRepository.save(j);
        });
    }

    public Long obtenerIdPorEmail(String email) {
        return jugadorRepository.findByEmail(email)
                .map(Jugador::getId)
                .orElse(null);
    }

    public List<JugadorResponse> listar() {
        return jugadorRepository.findAll()
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<JugadorResponse> listarPorEquipo(Long equipoId) {
        return jugadorRepository.findByEquipoId(equipoId)
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<JugadorResponse> listarSinEquipo() {
        return jugadorRepository.findByEquipoIsNull()
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public List<JugadorResponse> listarPorPosicion(String posicion) {
        return jugadorRepository.findByPosicion(posicion)
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public JugadorResponse obtenerPorId(Long id) {
        return jugadorRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Jugador no encontrado"));
    }

    public Jugador obtenerPorCodigo(String codigo) {
        return jugadorRepository.findByCodigoJugador(codigo)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Jugador no encontrado"));
    }

    @Transactional
    public JugadorResponse actualizar(Long id, JugadorRequest dto) {
        Jugador jugador = jugadorRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Jugador no encontrado"));

        if (dto.getPosicion() != null) jugador.setPosicion(dto.getPosicion());
        if (dto.getDorsal() > 0) jugador.setDorsal(dto.getDorsal());
        if (dto.getAltura() > 0) jugador.setAltura(dto.getAltura());
        if (dto.getPeso() > 0) jugador.setPeso(dto.getPeso());
        if (dto.getEquipoId() != null) {
            Equipo equipo = equipoRepository.findById(dto.getEquipoId())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Equipo no encontrado"));
            jugador.setEquipo(equipo);
        }

        return toResponse(jugadorRepository.save(jugador));
    }

    @Transactional
    public void eliminar(Long id) {
        if (!jugadorRepository.existsById(id))
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Jugador no encontrado");
        jugadorRepository.deleteById(id);
    }

    @Transactional
    public JugadorResponse crearJugador(JugadorRequest dto) {
        log.info("Creando jugador: {}", dto.getUsername());

        if (jugadorRepository.existsByUsername(dto.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El username ya está en uso");
        }
        if (jugadorRepository.existsByEmail(dto.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El email ya está registrado");
        }
        if (dto.getCodigoJugador() != null && jugadorRepository.existsByCodigoJugador(dto.getCodigoJugador())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El código de jugador ya está en uso");
        }

        Equipo equipo = null;
        if (dto.getEquipoId() != null) {
            equipo = equipoRepository.findById(dto.getEquipoId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                            "Equipo no encontrado con ID: " + dto.getEquipoId()));
        }

        Jugador jugador = new Jugador();
        jugador.setNombre(dto.getNombre());
        jugador.setApellido(dto.getApellido());
        jugador.setUsername(dto.getUsername());
        jugador.setEmail(dto.getEmail());
        jugador.setPassword(passwordEncoder.encode(dto.getPassword()));
        jugador.setEdad(dto.getEdad());
        jugador.setAltura(dto.getAltura());
        jugador.setPeso(dto.getPeso());
        jugador.setPosicion(dto.getPosicion());
        jugador.setDorsal(dto.getDorsal());
        jugador.setCodigoJugador(dto.getCodigoJugador() != null ? dto.getCodigoJugador() : generarCodigoJugador());
        jugador.setRole(Roles.JUGADOR);
        jugador.setEquipo(equipo);
        jugador.setVerificado(false);

        jugador.setPuntosTotales(0);
        jugador.setRebotesTotales(0);
        jugador.setAsistenciasTotales(0);
        jugador.setRobosTotales(0);
        jugador.setPartidosJugados(0);

        return toResponse(jugadorRepository.save(jugador));
    }

    @Transactional
    public List<JugadorResponse> buscarJugadores(String query) {
        String lowerQuery = query.toLowerCase();

        return jugadorRepository.findAll().stream()
                .filter(j -> (j.getNombre() != null && j.getNombre().toLowerCase().contains(lowerQuery)) ||
                        (j.getApellido() != null && j.getApellido().toLowerCase().contains(lowerQuery)) ||
                        (j.getUsername() != null && j.getUsername().toLowerCase().contains(lowerQuery)) ||
                        (j.getPosicion() != null && j.getPosicion().toLowerCase().contains(lowerQuery)))
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public List<JugadorResponse> getRankingPuntos(int limit) {
        return jugadorRepository.findAll().stream()
                .sorted((a, b) -> Integer.compare(b.getPuntosTotales(), a.getPuntosTotales()))
                .limit(limit)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public List<JugadorResponse> getRankingRebotes(int limit) {
        return jugadorRepository.findAll().stream()
                .sorted((a, b) -> Integer.compare(b.getRebotesTotales(), a.getRebotesTotales()))
                .limit(limit)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public List<JugadorResponse> getRankingAsistencias(int limit) {
        return jugadorRepository.findAll().stream()
                .sorted((a, b) -> Integer.compare(b.getAsistenciasTotales(), a.getAsistenciasTotales()))
                .limit(limit)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public List<JugadorResponse> getRankingRobos(int limit) {
        return jugadorRepository.findAll().stream()
                .sorted((a, b) -> Integer.compare(b.getRobosTotales(), a.getRobosTotales()))
                .limit(limit)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public JugadorResponse asignarEquipo(Long jugadorId, Long equipoId) {
        Jugador jugador = jugadorRepository.findById(jugadorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Jugador no encontrado con ID: " + jugadorId));

        Equipo equipo = equipoRepository.findById(equipoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + equipoId));

        jugador.setEquipo(equipo);
        return toResponse(jugadorRepository.save(jugador));
    }

    @Transactional
    public JugadorResponse desasignarEquipo(Long jugadorId) {
        Jugador jugador = jugadorRepository.findById(jugadorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Jugador no encontrado con ID: " + jugadorId));

        jugador.setEquipo(null);
        return toResponse(jugadorRepository.save(jugador));
    }

    @Transactional
    public JugadorResponse obtenerPorUsername(String username) {
        Jugador jugador = jugadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Jugador no encontrado con username: " + username));
        return toResponse(jugador);
    }

    @Transactional
    public List<JugadorResponse> getJugadoresDestacados(int limit) {
        return jugadorRepository.findAll().stream()
                .filter(j -> j.getPartidosJugados() > 0)
                .sorted((a, b) -> {
                    double avgA = a.getPuntosTotales() / (double) a.getPartidosJugados();
                    double avgB = b.getPuntosTotales() / (double) b.getPartidosJugados();
                    return Double.compare(avgB, avgA);
                })
                .limit(limit)
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public Map<String, Object> getEstadisticasCompletas(Long jugadorId) {
        Jugador jugador = jugadorRepository.findById(jugadorId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Jugador no encontrado con ID: " + jugadorId));

        int partidosJugados = jugador.getPartidosJugados();
        int puntosTotales = jugador.getPuntosTotales();
        int rebotesTotales = jugador.getRebotesTotales();
        int asistenciasTotales = jugador.getAsistenciasTotales();
        int robosTotales = jugador.getRobosTotales();

        double promedioPuntos = partidosJugados > 0 ? puntosTotales / (double) partidosJugados : 0;
        double promedioRebotes = partidosJugados > 0 ? rebotesTotales / (double) partidosJugados : 0;
        double promedioAsistencias = partidosJugados > 0 ? asistenciasTotales / (double) partidosJugados : 0;
        double promedioRobos = partidosJugados > 0 ? robosTotales / (double) partidosJugados : 0;

        return Map.ofEntries(
                Map.entry("jugadorId", jugador.getId()),
                Map.entry("nombreCompleto", jugador.getNombre() + " " + jugador.getApellido()),
                Map.entry("username", jugador.getUsername()),
                Map.entry("posicion", jugador.getPosicion()),
                Map.entry("dorsal", jugador.getDorsal()),
                Map.entry("altura", jugador.getAltura()),
                Map.entry("peso", jugador.getPeso()),
                Map.entry("edad", jugador.getEdad()),
                Map.entry("equipo", jugador.getEquipo() != null ? jugador.getEquipo().getNombre() : "Sin equipo"),
                Map.entry("equipoId", jugador.getEquipo() != null ? jugador.getEquipo().getId() : null),
                Map.entry("partidosJugados", partidosJugados),
                Map.entry("puntosTotales", puntosTotales),
                Map.entry("rebotesTotales", rebotesTotales),
                Map.entry("asistenciasTotales", asistenciasTotales),
                Map.entry("robosTotales", robosTotales),
                Map.entry("promedioPuntos", Math.round(promedioPuntos * 10) / 10.0),
                Map.entry("promedioRebotes", Math.round(promedioRebotes * 10) / 10.0),
                Map.entry("promedioAsistencias", Math.round(promedioAsistencias * 10) / 10.0),
                Map.entry("promedioRobos", Math.round(promedioRobos * 10) / 10.0)
        );
    }

    private void validarCodigoJugador(String codigo) {
        if (codigo == null || !codigo.matches("^JUG-\\d{4}-\\d{3}$"))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Código de jugador inválido. " +
                            "Formato: JUG-XXXX-NNN (ej: JUG-2024-001)");
        if (jugadorRepository.existsByCodigoJugador(codigo))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este código ya está registrado");
    }

    private String generarCodigoJugador() {
        String codigo;
        do {
            int numero = 100000 + random.nextInt(900000);
            codigo = "JUG-" + numero;
        } while (jugadorRepository.existsByCodigoJugador(codigo));
        return codigo;
    }

    private JugadorResponse toResponse(Jugador j) {
        JugadorResponse r = new JugadorResponse();
        r.setId(j.getId());
        r.setNombre(j.getNombre());
        r.setApellido(j.getApellido());
        r.setUsername(j.getUsername());
        r.setEmail(j.getEmail());
        r.setEdad(j.getEdad());
        r.setAltura(j.getAltura());
        r.setPeso(j.getPeso());
        r.setPosicion(j.getPosicion());
        r.setDorsal(j.getDorsal());
        r.setRole(j.getRole() != null ? j.getRole().name() : null);
        r.setEquipoId(j.getEquipo() != null ? j.getEquipo().getId() : null);
        r.setEquipoNombre(j.getEquipo() != null ? j.getEquipo().getNombre() : null);
        r.setLigaNombre(j.getEquipo() != null && j.getEquipo().getLiga() != null ?
                j.getEquipo().getLiga().getNombreLiga() : null);

        r.setPuntosTotales(j.getPuntosTotales());
        r.setRebotesTotales(j.getRebotesTotales());
        r.setAsistenciasTotales(j.getAsistenciasTotales());
        r.setRobosTotales(j.getRobosTotales());
        r.setPartidosJugados(j.getPartidosJugados());

        return r;
    }
}
