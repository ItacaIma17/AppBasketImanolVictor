package Aplicacion.Services;

import Dominio.Entity.Equipo;
import Dominio.Entity.Jugador;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.JugadorRepository;
import Presentacion.DTOS.Jugador.JugadorRequest;
import Presentacion.DTOS.Jugador.JugadorResponse;
import Presentacion.DTOS.Usuarios.Register.RegistroJugadorDTO;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class JugadorService {

    private final JugadorRepository jugadorRepository;
    private final EquipoRepository equipoRepository;

    // ── Llamado desde UserService al registrarse ──────────

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

    // ── CRUD ──────────────────────────────────────────────

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
        if (dto.getDorsal() != 0) jugador.setDorsal(dto.getDorsal());
        if (dto.getAltura() != 0) jugador.setAltura(dto.getAltura());
        if (dto.getPeso() != 0) jugador.setPeso(dto.getPeso());
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

    // ── PRIVADOS ──────────────────────────────────────────

    private void validarCodigoJugador(String codigo) {
        if (codigo == null || !codigo.matches("^JUG-\\d{4}-\\d{3}$"))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Código de jugador inválido. " +
                            "Formato: JUG-XXXX-NNN (ej: JUG-2024-001)");
        if (jugadorRepository.existsByCodigoJugador(codigo))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este código ya está registrado");
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
        return r;
    }
}