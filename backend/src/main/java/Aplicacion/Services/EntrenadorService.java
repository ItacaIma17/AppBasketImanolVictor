// Aplicacion/Services/EntrenadorService.java
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

    // Generar código único para entrenador
    public String generarCodigoEntrenador() {
        String codigo;
        do {
            int numero = 100000 + random.nextInt(900000);
            codigo = CODIGO_PREFIX + numero;
        } while (entrenadorRepository.existsByCodigoEntrenador(codigo));

        log.info("Código de entrenador generado: {}", codigo);
        return codigo;
    }

    // Crear entrenador desde DTO (admin)
    @Transactional
    public EntrenadorRequest crearEntrenador(CrearEntrenadorDTO dto) {
        log.info("Creando entrenador: {}", dto.getUsername());

        // Validaciones
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

        // Crear entrenador
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

    // Crear entrenador desde registro (con código)
    @Transactional
    public Entrenador crearDesdeRegistro(RegisterEntrenadorDTO dto, Usuario usuario) {
        log.info("Creando entrenador desde registro con código: {}", dto.getCodigoEntrenador());

        if (dto.getCodigoEntrenador() == null || dto.getCodigoEntrenador().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "El código de entrenador es obligatorio");
        }

        if (!dto.getCodigoEntrenador().startsWith(CODIGO_PREFIX)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Código de entrenador inválido. Debe comenzar con " + CODIGO_PREFIX);
        }

        Entrenador entrenador = new Entrenador();
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
        log.info("Entrenador creado desde registro con ID: {}", saved.getId());

        return saved;
    }

    // Asignar equipo a entrenador
    @Transactional
    public EntrenadorEquipoDTO asignarEquipoAEntrenador(AsignarEquipoDTO dto, String adminUsername) {
        log.info("Admin {} asignando equipo {} a entrenador con código {}",
                adminUsername, dto.getEquipoId(), dto.getCodigoEntrenador());

        Usuario admin = userRepository.findByUsername(adminUsername);
        if (admin == null || admin.getRole() != Roles.ADMIN) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Solo administradores pueden asignar equipos");
        }

        Entrenador entrenador = entrenadorRepository.findByCodigoEntrenador(dto.getCodigoEntrenador())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con el código: " + dto.getCodigoEntrenador()));

        Equipo equipo = equipoRepository.findById(dto.getEquipoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Equipo no encontrado"));

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

        log.info("Equipo '{}' asignado a entrenador '{}'", equipo.getNombre(), entrenador.getNombre());

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

    // Obtener equipo del entrenador autenticado
    @Transactional(readOnly = true)
    public EntrenadorEquipoDTO obtenerMiEquipo(String username) {
        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado"));

        if (entrenador.getEquipo() == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Aún no tienes un equipo asignado. Contacta con el administrador.");
        }

        Equipo equipo = entrenador.getEquipo();

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

    // Listar todos los entrenadores
    @Transactional(readOnly = true)
    public List<EntrenadorRequest> listarTodosEntrenadores() {
        return EntrenadorRequest.fromEntityList(entrenadorRepository.findAll());
    }

    // Listar entrenadores sin equipo
    @Transactional(readOnly = true)
    public List<EntrenadorRequest> listarEntrenadoresSinEquipo() {
        return EntrenadorRequest.fromEntityList(entrenadorRepository.findEntrenadoresSinEquipo());
    }

    // Listar entrenadores con equipo
    @Transactional(readOnly = true)
    public List<EntrenadorRequest> listarEntrenadoresConEquipo() {
        return EntrenadorRequest.fromEntityList(entrenadorRepository.findEntrenadoresConEquipo());
    }

    // Obtener entrenador por ID
    @Transactional(readOnly = true)
    public EntrenadorRequest obtenerEntrenadorPorId(Long id) {
        Entrenador entrenador = entrenadorRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con ID: " + id));
        return EntrenadorRequest.fromEntity(entrenador);
    }

    // Obtener entrenador por username
    @Transactional(readOnly = true)
    public EntrenadorRequest obtenerEntrenadorPorUsername(String username) {
        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado con username: " + username));
        return EntrenadorRequest.fromEntity(entrenador);
    }

    // Actualizar password
    public void actualizarPassword(String email, String nuevaPasswordEncriptada) {
        Entrenador entrenador = entrenadorRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Entrenador no encontrado"));
        entrenador.setPassword(nuevaPasswordEncriptada);
        entrenadorRepository.save(entrenador);
        log.info("Password actualizado para entrenador: {}", email);
    }

    // Obtener ID por email
    public Long obtenerIdPorEmail(String email) {
        return entrenadorRepository.findByEmail(email)
                .map(Entrenador::getId)
                .orElse(null);
    }

    // Marcar como verificado
    public void marcarComoVerificado(String email) {
        Entrenador entrenador = entrenadorRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Entrenador no encontrado"));
        entrenador.setVerificado(true);
        entrenadorRepository.save(entrenador);
        log.info("Entrenador verificado: {}", email);
    }

    // Eliminar entrenador
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