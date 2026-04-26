package Aplicacion.Services;

import Dominio.Entity.Arbitro;
import Dominio.Entity.Partido;
import Dominio.Entity.Usuario;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.ArbitroRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Arbitro.ArbitroRequest;
import Presentacion.DTOS.Arbitro.ArbitroResponse;
import Presentacion.DTOS.Arbitro.AsignarArbitroDTO;
import Presentacion.DTOS.Partido.PartidoResponseDTO;
import Presentacion.DTOS.Usuarios.Register.RegistroArbitroDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ArbitroService {

    private final ArbitroRepository arbitroRepository;
    private final PartidoRepository partidoRepository;
    private final PasswordEncoder passwordEncoder;

    private static final String CODIGO_PREFIX = "ARB-";
    private static final SecureRandom random = new SecureRandom();

    // Generar código único para árbitro
    public String generarCodigoArbitro() {
        String codigo;
        do {
            int numero = 100000 + random.nextInt(900000);
            codigo = CODIGO_PREFIX + numero;
        } while (arbitroRepository.existsByCodigoArbitro(codigo));

        log.info("Código de árbitro generado: {}", codigo);
        return codigo;
    }

    // ============================================================
    // MÉTODOS PARA UserService
    // ============================================================

    /**
     * Crear árbitro desde registro (cuando se registra un nuevo árbitro)
     */

    @Transactional
    public Arbitro crearDesdeRegistro(RegistroArbitroDTO dto, Usuario usuario) {
        log.info("Creando árbitro desde registro con código: {}", dto.getCodigoArbitro());

        if (dto.getCodigoArbitro() == null || dto.getCodigoArbitro().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "El código de árbitro es obligatorio");
        }

        // Validar formato del código (debe comenzar con ARB-)
        if (!dto.getCodigoArbitro().startsWith(CODIGO_PREFIX)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Código de árbitro inválido. Debe comenzar con " + CODIGO_PREFIX);
        }

        // Buscar si ya existe un árbitro con ese código (puede ser null)
        Arbitro arbitro = arbitroRepository.findByCodigoArbitro(dto.getCodigoArbitro())
                .orElse(null);

        // Si no existe, crear uno nuevo
        if (arbitro == null) {
            log.info("Código no existente, creando nuevo árbitro con código: {}", dto.getCodigoArbitro());
            arbitro = new Arbitro();
            arbitro.setCodigoArbitro(dto.getCodigoArbitro());
            arbitro.setRole(Roles.ARBITRO);
        }

        // Verificar que el código no esté ya asociado a otro usuario
        if (arbitro.getUsuario() != null && !arbitro.getUsuario().getId().equals(usuario.getId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este código ya ha sido utilizado por otro árbitro");
        }

        // Asignar datos del usuario al árbitro
        arbitro.setNombre(dto.getNombre());
        arbitro.setApellidos(dto.getApellidos());
        arbitro.setUsername(usuario.getUsername());
        arbitro.setPassword(usuario.getPassword());
        arbitro.setEmail(usuario.getEmail());
        arbitro.setEdad(dto.getEdad());
        arbitro.setRole(Roles.ARBITRO);
        arbitro.setVerificado(usuario.isVerificado());
        arbitro.setUsuario(usuario);

        Arbitro saved = arbitroRepository.save(arbitro);
        log.info("✅ Árbitro creado desde registro con ID: {}, Código: {}", saved.getId(), saved.getCodigoArbitro());

        return saved;
    }

    /**
     * Marcar árbitro como verificado
     */
    @Transactional
    public void marcarComoVerificado(String email) {
        log.info("Marcando árbitro como verificado: {}", email);

        Arbitro arbitro = arbitroRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Árbitro no encontrado con email: " + email));

        arbitro.setVerificado(true);
        arbitroRepository.save(arbitro);
        log.info("Árbitro verificado: {}", email);
    }

    /**
     * Actualizar contraseña del árbitro
     */
    @Transactional
    public void actualizarPassword(String email, String nuevaPasswordEncriptada) {
        log.info("Actualizando contraseña para árbitro: {}", email);

        Arbitro arbitro = arbitroRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Árbitro no encontrado con email: " + email));

        arbitro.setPassword(nuevaPasswordEncriptada);
        arbitroRepository.save(arbitro);
        log.info("Contraseña actualizada para árbitro: {}", email);
    }

    /**
     * Obtener ID por email
     */
    public Long obtenerIdPorEmail(String email) {
        return arbitroRepository.findByEmail(email)
                .map(Arbitro::getId)
                .orElse(null);
    }

    // ============================================================
    // MÉTODOS PARA EL CONTROLLER
    // ============================================================

    /**
     * Obtener partidos asignados al árbitro
     */
    public List<PartidoResponseDTO> getPartidosAsignados(String username) {
        log.info("Obteniendo partidos asignados al árbitro: {}", username);

        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado: " + username));

        return partidoRepository.findByArbitroId(arbitro.getId()).stream()
                .map(PartidoResponseDTO::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Obtener alineaciones de un partido para el acta
     */
    public Object getAlineacionesPartido(Long partidoId) {
        log.info("Obteniendo alineaciones para acta del partido: {}", partidoId);

        // Este método debe devolver las alineaciones de ambos equipos
        // Puedes implementarlo llamando a AlineacionService
        // Por ahora devolvemos un objeto vacío
        return Map.of(
                "partidoId", partidoId,
                "alineacionLocal", null,
                "alineacionVisitante", null
        );
    }

    /**
     * Asignar árbitro a un partido (solo admin)
     */
    @Transactional
    public void asignarArbitroAPartido(AsignarArbitroDTO dto) {
        log.info("Asignando árbitro {} al partido {}", dto.getArbitroId(), dto.getPartidoId());

        Arbitro arbitro = arbitroRepository.findById(dto.getArbitroId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + dto.getArbitroId()));

        Partido partido = partidoRepository.findById(dto.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + dto.getPartidoId()));

        // Verificar que el partido no tenga ya un acta
        if (partido.getActa() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Este partido ya tiene un acta finalizada");
        }

        partido.setArbitro(arbitro);
        partidoRepository.save(partido);

        log.info("Árbitro {} asignado al partido {}", arbitro.getNombre(), partido.getId());
    }

    /**
     * Obtener árbitros sin partidos asignados (disponibles)
     */
    public List<ArbitroResponse> getArbitrosSinPartidos() {
        log.info("Listando árbitros sin partidos asignados");

        return arbitroRepository.findArbitrosSinPartidos().stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    // ============================================================
    // MÉTODOS DE ADMINISTRACIÓN
    // ============================================================

    /**
     * Crear árbitro desde DTO (admin)
     */
    @Transactional
    public Arbitro crearArbitro(ArbitroRequest dto) {
        log.info("Creando árbitro: {}", dto.getUsername());

        // Validaciones
        if (arbitroRepository.existsByUsername(dto.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El username ya está en uso");
        }

        if (arbitroRepository.existsByEmail(dto.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El email ya está registrado");
        }

        if (dto.getCodigoArbitro() != null && arbitroRepository.existsByCodigoArbitro(dto.getCodigoArbitro())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "El código de árbitro ya está en uso");
        }

        // Crear árbitro
        Arbitro arbitro = new Arbitro();
        arbitro.setNombre(dto.getNombre());
        arbitro.setApellidos(dto.getApellidos());
        arbitro.setUsername(dto.getUsername());
        arbitro.setPassword(passwordEncoder.encode(dto.getPassword()));
        arbitro.setEmail(dto.getEmail());
        arbitro.setEdad(dto.getEdad());
        arbitro.setCodigoArbitro(dto.getCodigoArbitro() != null ? dto.getCodigoArbitro() : generarCodigoArbitro());
        arbitro.setRole(Roles.ARBITRO);
        arbitro.setVerificado(false);

        Arbitro saved = arbitroRepository.save(arbitro);
        log.info("Árbitro creado con ID: {}", saved.getId());

        return saved;
    }

    /**
     * Obtener todos los árbitros
     */
    public List<ArbitroResponse> listarTodosArbitros() {
        return arbitroRepository.findAll().stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Obtener árbitros disponibles (sin partidos asignados)
     */
    public List<ArbitroResponse> listarArbitrosDisponibles() {
        return arbitroRepository.findArbitrosSinPartidos().stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * Obtener árbitro por ID
     */
    public ArbitroResponse obtenerArbitroPorId(Long id) {
        Arbitro arbitro = arbitroRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + id));
        return ArbitroResponse.fromEntity(arbitro);
    }

    /**
     * Obtener árbitro por username
     */
    public ArbitroResponse obtenerArbitroPorUsername(String username) {
        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con username: " + username));
        return ArbitroResponse.fromEntity(arbitro);
    }

    /**
     * Eliminar árbitro
     */
    @Transactional
    public void eliminarArbitro(Long id) {
        log.info("Eliminando árbitro con ID: {}", id);

        if (!arbitroRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Árbitro no encontrado con ID: " + id);
        }

        arbitroRepository.deleteById(id);
        log.info("Árbitro eliminado con ID: {}", id);
    }
}