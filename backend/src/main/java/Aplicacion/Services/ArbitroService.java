package Aplicacion.Services;

import Dominio.Entity.Alineacion;
import Dominio.Entity.Arbitro;
import Dominio.Entity.Partido;
import Dominio.Entity.Usuario;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.AlineacionRepository;
import Dominio.Repositorys.ArbitroRepository;
import Dominio.Repositorys.PartidoRepository;
import Presentacion.DTOS.Alineacion.AlineacionesParaPartidoDTO;
import Presentacion.DTOS.Alineacion.AlineacionesPartidoDTO;
import Presentacion.DTOS.Arbitro.ArbitroEstadisticasResponse;
import Presentacion.DTOS.Arbitro.ArbitroRequest;
import Presentacion.DTOS.Arbitro.ArbitroResponse;
import Presentacion.DTOS.Arbitro.AsignarArbitroDTO;
import Presentacion.DTOS.Partido.PartidoResponse;
import Presentacion.DTOS.Usuarios.Register.RegistroArbitroDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import jakarta.mail.MessagingException;
import java.security.SecureRandom;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ArbitroService {

    private final ArbitroRepository arbitroRepository;
    private final PartidoRepository partidoRepository;
    private final PasswordEncoder passwordEncoder;
    private final AlineacionService alineacionService;
    private final AlineacionRepository alineacionRepository;
    private final EmailService emailService;

    private static final String CODIGO_PREFIX = "ARB-";
    private static final SecureRandom random = new SecureRandom();

    public String generarCodigoArbitro() {
        String codigo;
        do {
            int numero = 100000 + random.nextInt(900000);
            codigo = CODIGO_PREFIX + numero;
        } while (arbitroRepository.existsByCodigoArbitro(codigo));
        log.info("Código de árbitro generado: {}", codigo);
        return codigo;
    }

    @Transactional
    public Arbitro crearDesdeRegistro(RegistroArbitroDTO dto, Usuario usuario) {
        log.info("Creando árbitro desde registro con código: {}", dto.getCodigoArbitro());

        if (dto.getCodigoArbitro() == null || dto.getCodigoArbitro().isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El código de árbitro es obligatorio");
        }

        if (!dto.getCodigoArbitro().startsWith(CODIGO_PREFIX)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Código de árbitro inválido. Debe comenzar con " + CODIGO_PREFIX);
        }

        Arbitro arbitro = arbitroRepository.findByCodigoArbitro(dto.getCodigoArbitro()).orElse(null);

        if (arbitro == null) {
            log.info("Código no existente, creando nuevo árbitro con código: {}", dto.getCodigoArbitro());
            arbitro = new Arbitro();
            arbitro.setCodigoArbitro(dto.getCodigoArbitro());
            arbitro.setRole(Roles.ARBITRO);
        }

        if (arbitro.getUsuario() != null && !arbitro.getUsuario().getId().equals(usuario.getId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Este código ya ha sido utilizado por otro árbitro");
        }

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
        log.info(" Árbitro creado desde registro con ID: {}", saved.getId());
        return saved;
    }

    @Transactional
    public void marcarComoVerificado(String email) {
        Arbitro arbitro = arbitroRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con email: " + email));
        arbitro.setVerificado(true);
        arbitroRepository.save(arbitro);
    }

    @Transactional
    public void actualizarPassword(String email, String nuevaPasswordEncriptada) {
        Arbitro arbitro = arbitroRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con email: " + email));
        arbitro.setPassword(nuevaPasswordEncriptada);
        arbitroRepository.save(arbitro);
    }

    public Long obtenerIdPorEmail(String email) {
        return arbitroRepository.findByEmail(email).map(Arbitro::getId).orElse(null);
    }

    public List<PartidoResponse> getPartidosAsignados(String username) {
        log.info("Obteniendo partidos asignados al árbitro: {}", username);

        if (username == null || username.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username no proporcionado");
        }

        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con username: " + username));

        List<Partido> partidos = partidoRepository.findByArbitroId(arbitro.getId());

        if (partidos.isEmpty()) {
            return List.of();
        }

        return partidos.stream()
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public AlineacionesPartidoDTO getAlineacionesPartido(Long partidoId) {
        log.info("Obteniendo alineaciones para acta del partido: {}", partidoId);
        return alineacionService.getAlineacionesParaActa(partidoId);
    }

    public List<PartidoResponse> getPartidosFinalizados(Long arbitroId) {
        Arbitro arbitro = arbitroRepository.findById(arbitroId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + arbitroId));
        return arbitro.getPartidos().stream()
                .filter(p -> p.getEstado() != null && "FINALIZADO".equals(p.getEstado()))
                .map(PartidoResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ArbitroResponse> listarTodosArbitros() {
        return arbitroRepository.findAll().stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ArbitroResponse> listarArbitrosDisponibles() {
        return arbitroRepository.findArbitrosSinPartidos().stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<ArbitroResponse> getArbitrosSinPartidos() {
        return arbitroRepository.findArbitrosSinPartidos().stream()
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public ArbitroResponse obtenerArbitroPorId(Long id) {
        Arbitro arbitro = arbitroRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + id));
        return ArbitroResponse.fromEntity(arbitro);
    }

    public ArbitroResponse obtenerArbitroPorUsername(String username) {
        Arbitro arbitro = arbitroRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con username: " + username));
        return ArbitroResponse.fromEntity(arbitro);
    }

    public List<ArbitroResponse> buscarArbitros(String query) {
        String lowerQuery = query.toLowerCase();
        return arbitroRepository.findAll().stream()
                .filter(a -> (a.getNombre() != null && a.getNombre().toLowerCase().contains(lowerQuery)) ||
                        (a.getApellidos() != null && a.getApellidos().toLowerCase().contains(lowerQuery)) ||
                        (a.getUsername() != null && a.getUsername().toLowerCase().contains(lowerQuery)) ||
                        (a.getEmail() != null && a.getEmail().toLowerCase().contains(lowerQuery)))
                .map(ArbitroResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public ArbitroEstadisticasResponse obtenerEstadisticas(Long id) {
        Arbitro arbitro = arbitroRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + id));

        List<Partido> partidos = arbitro.getPartidos();
        long totalPartidos = partidos.size();
        long partidosFinalizados = partidos.stream()
                .filter(p -> p.getEstado() != null && "FINALIZADO".equals(p.getEstado()))
                .count();

        String nombreCompleto = (arbitro.getNombre() != null ? arbitro.getNombre() : "") +
                " " + (arbitro.getApellidos() != null ? arbitro.getApellidos() : "");

        return ArbitroEstadisticasResponse.builder()
                .id(arbitro.getId())
                .nombre(nombreCompleto.trim())
                .totalPartidosAsignados((int) totalPartidos)
                .partidosFinalizados((int) partidosFinalizados)
                .partidosPendientes((int) (totalPartidos - partidosFinalizados))
                .verificado(arbitro.getVerificado())
                .build();
    }

    public ArbitroResponse crearArbitro(ArbitroRequest dto) {
        log.info("Creando árbitro: {}", dto.getUsername());

        if (arbitroRepository.existsByUsername(dto.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El username ya está en uso");
        }
        if (arbitroRepository.existsByEmail(dto.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El email ya está registrado");
        }
        if (dto.getCodigoArbitro() != null && arbitroRepository.existsByCodigoArbitro(dto.getCodigoArbitro())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El código de árbitro ya está en uso");
        }

        String plainPassword = dto.getPassword();
        Arbitro arbitro = new Arbitro();
        arbitro.setNombre(dto.getNombre());
        arbitro.setApellidos(dto.getApellidos());
        arbitro.setUsername(dto.getUsername());
        arbitro.setPassword(passwordEncoder.encode(plainPassword));
        arbitro.setEmail(dto.getEmail());
        arbitro.setEdad(dto.getEdad());
        arbitro.setCodigoArbitro(dto.getCodigoArbitro() != null ? dto.getCodigoArbitro() : generarCodigoArbitro());
        arbitro.setRole(Roles.ARBITRO);
        arbitro.setVerificado(false);

        Arbitro saved = arbitroRepository.save(arbitro);

        try {
            emailService.enviarBienvenidaArbitro(saved.getEmail(), saved.getNombre(), saved.getUsername(), plainPassword);
        } catch (MessagingException e) {
            log.warn("Email de bienvenida no enviado al árbitro {}: {}", saved.getEmail(), e.getMessage());
        }

        return ArbitroResponse.fromEntity(saved);
    }

    public ArbitroResponse actualizarArbitro(Long id, ArbitroRequest dto) {
        Arbitro arbitro = arbitroRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + id));

        if (!arbitro.getUsername().equals(dto.getUsername()) && arbitroRepository.existsByUsername(dto.getUsername())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El username ya está en uso");
        }
        if (!arbitro.getEmail().equals(dto.getEmail()) && arbitroRepository.existsByEmail(dto.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El email ya está registrado");
        }

        arbitro.setNombre(dto.getNombre());
        arbitro.setApellidos(dto.getApellidos());
        arbitro.setUsername(dto.getUsername());
        arbitro.setEmail(dto.getEmail());
        arbitro.setEdad(dto.getEdad());

        if (dto.getPassword() != null && !dto.getPassword().isEmpty()) {
            arbitro.setPassword(passwordEncoder.encode(dto.getPassword()));
        }

        return ArbitroResponse.fromEntity(arbitroRepository.save(arbitro));
    }

    @Transactional
    public void verificarArbitro(Long id) {
        Arbitro arbitro = arbitroRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + id));
        arbitro.setVerificado(true);
        arbitroRepository.save(arbitro);
    }

    @Transactional
    public ArbitroResponse cambiarEstado(Long id, Boolean activo) {
        Arbitro arbitro = arbitroRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + id));
        arbitro.setActivo(activo);
        return ArbitroResponse.fromEntity(arbitroRepository.save(arbitro));
    }

    @Transactional
    public void asignarArbitroAPartido(AsignarArbitroDTO dto) {
        Arbitro arbitro = arbitroRepository.findById(dto.getArbitroId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Árbitro no encontrado con ID: " + dto.getArbitroId()));

        Partido partido = partidoRepository.findById(dto.getPartidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Partido no encontrado con ID: " + dto.getPartidoId()));

        if (partido.getActaPartido() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Este partido ya tiene un acta finalizada");
        }

        partido.setArbitro(arbitro);
        partidoRepository.save(partido);
        log.info("Árbitro {} asignado al partido {}", arbitro.getNombre(), partido.getId());

        if (arbitro.getEmail() != null) {
            try {
                String pabellon = partido.getPabellon() != null ? partido.getPabellon() : partido.getUbicacion();
                emailService.enviarAsignacionPartidoArbitro(
                        arbitro.getEmail(),
                        arbitro.getNombre() + " " + arbitro.getApellidos(),
                        partido.getEquipoLocal().getNombre(),
                        partido.getEquipoVisitante().getNombre(),
                        partido.getFecha(),
                        pabellon != null ? pabellon : "Por confirmar");
            } catch (MessagingException e) {
                log.warn("Email de asignación no enviado al árbitro {}: {}", arbitro.getEmail(), e.getMessage());
            }
        }
    }

    @Transactional
    public void eliminarArbitro(Long id) {
        if (!arbitroRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Árbitro no encontrado con ID: " + id);
        }
        arbitroRepository.deleteById(id);
        log.info("Árbitro eliminado con ID: {}", id);
    }

    @Transactional
    public boolean confirmarAlineaciones(Long partidoId, String username) {
        Partido partido = partidoRepository.findById(partidoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Partido no encontrado"));

        if (partido.getArbitro() == null || !partido.getArbitro().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No eres el árbitro asignado a este partido");
        }

        Optional<Alineacion> local = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoLocal().getId());
        Optional<Alineacion> visitante = alineacionRepository
                .findByPartidoIdAndEquipoId(partidoId, partido.getEquipoVisitante().getId());

        if (local.isEmpty() || visitante.isEmpty()) {
            return false;
        }

        local.get().setConfirmada(true);
        visitante.get().setConfirmada(true);
        alineacionRepository.save(local.get());
        alineacionRepository.save(visitante.get());

        log.info(" Alineaciones confirmadas para partido {}", partidoId);
        return true;
    }
}
