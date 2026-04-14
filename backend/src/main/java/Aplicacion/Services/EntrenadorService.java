package Aplicacion.Services;

import Dominio.Entity.Entrenador;
import Dominio.Repositorys.EntrenadorRepository;
import Presentacion.DTOS.Entrenador.EntrenadorRequest;
import Presentacion.DTOS.Entrenador.EntrenadorResponse;
import Presentacion.DTOS.Usuarios.Register.RegisterEntrenadorDTO;
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
public class EntrenadorService {

    private final EntrenadorRepository entrenadorRepository;

    // ── Llamado desde UserService al registrarse ──────────

    @Transactional
    public void crearDesdeRegistro(RegisterEntrenadorDTO dto,
                                   Dominio.Entity.Usuario usuario) {
        validarCodigoEntrenador(dto.getCodigoEntrenador());

        if (entrenadorRepository.existsByEmail(dto.getEmail()))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un entrenador con este email");
        if (entrenadorRepository.existsByUsername(dto.getUsername()))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Ya existe un entrenador con este username");

        Entrenador entrenador = new Entrenador();

        entrenador.setUsuario(usuario);
        entrenador.setNombre(dto.getNombre());
        entrenador.setApellido(dto.getApellido());
        entrenador.setUsername(dto.getUsername());
        entrenador.setEmail(dto.getEmail());
        entrenador.setPassword(usuario.getPassword());
        entrenador.setEdad(dto.getEdad());
        entrenador.setCodigoEntrenador(dto.getCodigoEntrenador());
        entrenador.setRole(dto.getRol());
        entrenador.setVerificado(false);

        entrenadorRepository.save(entrenador);
        log.info("Entrenador creado: {}", entrenador.getEmail());
    }

    @Transactional
    public void marcarComoVerificado(String email) {
        entrenadorRepository.findByEmail(email).ifPresent(e -> {
            e.setVerificado(true);
            entrenadorRepository.save(e);
        });
    }

    @Transactional
    public void actualizarPassword(String email, String passwordEncriptada) {
        entrenadorRepository.findByEmail(email).ifPresent(e -> {
            e.setPassword(passwordEncriptada);
            entrenadorRepository.save(e);
        });
    }

    public Long obtenerIdPorEmail(String email) {
        return entrenadorRepository.findByEmail(email)
                .map(Entrenador::getId)
                .orElse(null);
    }

    // ── CRUD ──────────────────────────────────────────────

    public List<EntrenadorResponse> listar() {
        return entrenadorRepository.findAll()
                .stream().map(this::toResponse)
                .collect(Collectors.toList());
    }

    public EntrenadorResponse obtenerPorId(Long id) {
        return entrenadorRepository.findById(id)
                .map(this::toResponse)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Entrenador no encontrado"));
    }

    public Entrenador obtenerPorCodigo(String codigo) {
        return entrenadorRepository.findByCodigoEntrenador(codigo)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Entrenador no encontrado"));
    }

    @Transactional
    public EntrenadorResponse actualizar(Long id, EntrenadorRequest dto) {
        Entrenador entrenador = entrenadorRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Entrenador no encontrado"));

        if (dto.getNombre() != null) entrenador.setNombre(dto.getNombre());
        if (dto.getApellido() != null) entrenador.setApellido(dto.getApellido());
        if (dto.getEdad() != 0) entrenador.setEdad(dto.getEdad());

        return toResponse(entrenadorRepository.save(entrenador));
    }

    @Transactional
    public void eliminar(Long id) {
        if (!entrenadorRepository.existsById(id))
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Entrenador no encontrado");
        entrenadorRepository.deleteById(id);
    }

    // ── PRIVADOS ──────────────────────────────────────────

    private void validarCodigoEntrenador(String codigo) {
        if (codigo == null || !codigo.matches("^ENT-\\d{4}-\\d{3}$"))
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Código de entrenador inválido. " +
                            "Formato: ENT-XXXX-NNN (ej: ENT-2024-001)");
        if (entrenadorRepository.existsByCodigoEntrenador(codigo))
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este código ya está registrado");
    }

    private EntrenadorResponse toResponse(Entrenador e) {
        EntrenadorResponse r = new EntrenadorResponse();
        r.setId(e.getId());
        r.setNombre(e.getNombre());
        r.setApellido(e.getApellido());
        r.setUsername(e.getUsername());
        r.setEmail(e.getEmail());
        r.setEdad(e.getEdad());
        r.setRole(e.getRole() != null ? e.getRole().name() : null);
        r.setEquipoNombre(e.getEquipo() != null ? e.getEquipo().getNombre() : null);
        r.setEquipoId(e.getEquipo() != null ? e.getEquipo().getId() : null);
        return r;
    }
}