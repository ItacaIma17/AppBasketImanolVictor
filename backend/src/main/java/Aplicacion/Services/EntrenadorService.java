package Aplicacion.Services;

import Dominio.Entity.Entrenador;
import Dominio.Entity.Equipo;
import Dominio.Entity.Usuario;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.EntrenadorRepository;
import Dominio.Repositorys.EquipoRepository;
import Dominio.Repositorys.UserRepository;
import Presentacion.DTOS.Entrenador.AsignarEquipoDTO;
import Presentacion.DTOS.Entrenador.CrearEntrenadorDTO;
import Presentacion.DTOS.Entrenador.EntrenadorRequest;
import Presentacion.DTOS.Entrenador.EntrenadorEquipoDTO;
import Presentacion.DTOS.Usuarios.Register.RegisterEntrenadorDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EntrenadorService {

    private final EntrenadorRepository entrenadorRepository;
    private final EquipoRepository equipoRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    private static final String CODIGO_PREFIX = "ENT-";
    private static final SecureRandom random = new SecureRandom();

    public String generarCodigoEntrenador() {
        String codigo;
        do {
            int numero = 100000 + random.nextInt(900000);
            codigo = CODIGO_PREFIX + numero;
        } while (entrenadorRepository.existsByCodigoEntrenador(codigo));

        log.info("Código de entrenador generado: {}", codigo);
        return codigo;
    }

    @Transactional
    public EntrenadorRequest crearEntrenador(CrearEntrenadorDTO dto) {
        log.info("Creando entrenador: {}", dto.getUsername());

        if (entrenadorRepository.existsByUsername(dto.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El username ya está en uso");
        }

        if (entrenadorRepository.existsByEmail(dto.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El email ya está registrado");
        }

        if (entrenadorRepository.existsByCodigoEntrenador(dto.getCodigoEntrenador())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El código de entrenador ya está en uso");
        }

        Entrenador entrenador = new Entrenador();
        entrenador.setNombre(dto.getNombre());
        entrenador.setApellido(dto.getApellido());
        entrenador.setUsername(dto.getUsername());
        entrenador.setPassword(passwordEncoder.encode(dto.getPassword()));
        entrenador.setEmail(dto.getEmail());
        entrenador.setEdad(dto.getEdad());
        entrenador.setCodigoEntrenador(dto.getCodigoEntrenador());
        entrenador.setRole(Roles.ENTRENADOR);
        entrenador.setVerificado(false);
        entrenador.setTelefono(dto.getTelefono());
        entrenador.setExperiencia(dto.getExperiencia());

        Entrenador saved = entrenadorRepository.save(entrenador);
        log.info("Entrenador creado con ID: {}", saved.getId());

        return EntrenadorRequest.fromEntity(saved);
    }

    @Transactional
    public Entrenador crearDesdeRegistro(RegisterEntrenadorDTO dto, Usuario usuario) {
        log.info("Creando entrenador desde registro con código: {}", dto.getCodigoEntrenador());

        if (usuario.getUsername() == null || usuario.getUsername().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "El usuario no tiene username asignado");
        }

        log.info("   Username del usuario: {}", usuario.getUsername());
        log.info("   Email del usuario: {}", usuario.getEmail());

        Entrenador entrenador = entrenadorRepository.findByCodigoEntrenador(dto.getCodigoEntrenador())
                .orElse(new Entrenador());

        entrenador.setNombre(dto.getNombre());
        entrenador.setApellido(dto.getApellido());
        entrenador.setUsername(usuario.getUsername());
        entrenador.setPassword(usuario.getPassword());
        entrenador.setEmail(usuario.getEmail());
        entrenador.setEdad(dto.getEdad());
        entrenador.setCodigoEntrenador(dto.getCodigoEntrenador());
        entrenador.setRole(Roles.ENTRENADOR);
        entrenador.setVerificado(usuario.isVerificado());
        entrenador.setUsuario(usuario);

        Entrenador saved = entrenadorRepository.save(entrenador);
        log.info(" Entrenador creado con ID: {}, Username: {}", saved.getId(), saved.getUsername());

        return saved;
    }

    @Transactional
    public EntrenadorEquipoDTO asignarEquipoAEntrenador(AsignarEquipoDTO dto, String adminUsername) {
        log.info("Admin {} asignando equipo {} a entrenador con código {}",
                adminUsername, dto.getEquipoId(), dto.getCodigoEntrenador());

        Entrenador entrenador = entrenadorRepository.findByCodigoEntrenador(dto.getCodigoEntrenador())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con código: " + dto.getCodigoEntrenador()));

        Equipo equipo = equipoRepository.findById(dto.getEquipoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado con ID: " + dto.getEquipoId()));

        if (equipo.getEntrenador() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El equipo '" + equipo.getNombre() + "' ya tiene un entrenador asignado");
        }

        if (entrenador.getEquipo() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El entrenador '" + entrenador.getNombre() + "' ya tiene un equipo asignado");
        }

        entrenador.setEquipo(equipo);
        equipo.setEntrenador(entrenador);

        entrenadorRepository.save(entrenador);
        equipoRepository.save(equipo);

        log.info(" Equipo '{}' asignado a entrenador '{}'", equipo.getNombre(), entrenador.getNombre());

        Entrenador verificado = entrenadorRepository.findById(entrenador.getId()).get();
        log.info("Verificación - Entrenador {} tiene equipo: {}",
                verificado.getUsername(),
                verificado.getEquipo() != null ? verificado.getEquipo().getNombre() : "NO");

        return buildResponse(entrenador, equipo);
    }

    public EntrenadorEquipoDTO obtenerMiEquipo(String username) {
        log.info(" Buscando equipo del entrenador: {}", username);

        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado: " + username));

        log.info("Entrenador encontrado: ID={}, Nombre={}, Equipo={}",
                entrenador.getId(),
                entrenador.getNombre(),
                entrenador.getEquipo() != null ? entrenador.getEquipo().getId() : "NINGUNO");

        if (entrenador.getEquipo() == null) {
            log.warn("Entrenador {} no tiene equipo asignado", username);
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "El entrenador no tiene un equipo asignado");
        }

        Equipo equipo = entrenador.getEquipo();
        log.info("Equipo encontrado: ID={}, Nombre={}", equipo.getId(), equipo.getNombre());

        return buildResponse(entrenador, equipo);
    }

    private EntrenadorEquipoDTO buildResponse(Entrenador entrenador, Equipo equipo) {
        EntrenadorEquipoDTO response = new EntrenadorEquipoDTO();
        response.setEntrenadorId(entrenador.getId());
        response.setNombreEntrenador(entrenador.getNombre());
        response.setApellido(entrenador.getApellido());
        response.setEmail(entrenador.getEmail());
        response.setUsername(entrenador.getUsername());
        response.setEquipoId(equipo.getId());
        response.setNombreEquipo(equipo.getNombre());
        response.setNombreEstadio(equipo.getNombreEstadio());
        response.setNombreLiga(equipo.getLiga() != null ? equipo.getLiga().getNombreLiga() : "Sin liga");
        response.setTieneEquipo(true);
        return response;
    }

    @Transactional(readOnly = true)
    public List<EntrenadorRequest> listarTodosEntrenadores() {
        return EntrenadorRequest.fromEntityList(entrenadorRepository.findAll());
    }

    @Transactional(readOnly = true)
    public List<EntrenadorRequest> listarEntrenadoresSinEquipo() {
        return EntrenadorRequest.fromEntityList(entrenadorRepository.findEntrenadoresSinEquipo());
    }

    @Transactional(readOnly = true)
    public List<EntrenadorRequest> listarEntrenadoresConEquipo() {
        return EntrenadorRequest.fromEntityList(entrenadorRepository.findEntrenadoresConEquipo());
    }

    @Transactional(readOnly = true)
    public EntrenadorRequest obtenerEntrenadorPorId(Long id) {
        Entrenador entrenador = entrenadorRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con ID: " + id));
        return EntrenadorRequest.fromEntity(entrenador);
    }

    @Transactional(readOnly = true)
    public EntrenadorRequest obtenerEntrenadorPorUsername(String username) {
        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con username: " + username));
        return EntrenadorRequest.fromEntity(entrenador);
    }

    public void actualizarPassword(String email, String nuevaPasswordEncriptada) {
        Entrenador entrenador = entrenadorRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Entrenador no encontrado"));
        entrenador.setPassword(nuevaPasswordEncriptada);
        entrenadorRepository.save(entrenador);
        log.info("Password actualizado para entrenador: {}", email);
    }

    public Long obtenerIdPorEmail(String email) {
        return entrenadorRepository.findByEmail(email)
                .map(Entrenador::getId)
                .orElse(null);
    }

    public void marcarComoVerificado(String email) {
        Entrenador entrenador = entrenadorRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Entrenador no encontrado"));
        entrenador.setVerificado(true);
        entrenadorRepository.save(entrenador);
        log.info("Entrenador verificado: {}", email);
    }

    @Transactional
    public void eliminarEntrenador(Long id) {
        log.info("Eliminando entrenador con ID: {}", id);

        if (!entrenadorRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Entrenador no encontrado con ID: " + id);
        }

        entrenadorRepository.deleteById(id);
        log.info("Entrenador eliminado con ID: {}", id);
    }
}
