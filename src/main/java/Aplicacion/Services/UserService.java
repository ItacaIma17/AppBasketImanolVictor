package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.*;
import Presentacion.Config.JwtTokenProvider;
import Presentacion.DTOS.Equipo.SeguirEquipoDTO;
import Presentacion.DTOS.Jugador.JugadorResponse;
import Presentacion.DTOS.Jugador.SeguirReponseDTO;
import Presentacion.DTOS.Usuarios.ActualizarUsuarioDTO;
import Presentacion.DTOS.Usuarios.ChangePasswordDTO;
import Presentacion.DTOS.Usuarios.Login.LoginRequest;
import Presentacion.DTOS.Usuarios.Login.LoginResponse;
import Presentacion.DTOS.Usuarios.Login.VerificacionEmailDTO;
import Presentacion.DTOS.Usuarios.Register.*;
import Presentacion.DTOS.Usuarios.UsuarioPerfilDTO;
import jakarta.mail.MessagingException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.Principal;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository usuarioRepository;
    private final EmailVerificationRepository emailVerificationRepository;

    private final EntrenadorService entrenadorService;
    private final ArbitroService arbitroService;
    private final JugadorService jugadorService;
    private final JugadorRepository jugadorRepository;
    private final EquipoRepository equipoRepository;

    private final JwtTokenProvider jwtTokenProvider;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    // ──────────────────────────────────────────────
    // REGISTRO
    // ──────────────────────────────────────────────

    @Transactional
    public void registrarInicial(RegistroBaseDTO dto) {
        log.info("Iniciando registro para usuario: {} con rol: {}", dto.getUsername(), dto.getRol());

        validarRegistro(dto);
            // Crear usuario base
            Usuario usuario = crearUsuarioBase(dto);
            usuarioRepository.save(usuario);
            log.info("Usuario base creado con ID: {}", usuario.getId());

            // Crear entidad específica según el rol
            crearEntidadEspecifica(dto, usuario);

            // Generar y guardar código de verificación
            String codigo = generarCodigoVerificacion(dto.getEmail());

            // Enviar código por email
            enviarCodigoVerificacion(dto.getEmail(), codigo);

            log.info("Registro completado para: {}", dto.getEmail());

    }

    private Usuario crearUsuarioBase(RegistroBaseDTO dto) {
        Usuario usuario = new Usuario();
        usuario.setEmail(dto.getEmail());
        usuario.setUsername(dto.getUsername());
        usuario.setNombre(dto.getNombre());
        usuario.setEdad(dto.getEdad());
        usuario.setPassword(passwordEncoder.encode(dto.getPassword()));
        usuario.setRole(dto.getRol());
        usuario.setVerificado(false);
        usuario.setBloqueado(false);

        // Establecer apellido según el tipo de DTO
        if (dto instanceof RegisterEntrenadorDTO) {
            usuario.setApellido(((RegisterEntrenadorDTO) dto).getApellido());
        } else if (dto instanceof RegistroArbitroDTO) {
            usuario.setApellido(((RegistroArbitroDTO) dto).getApellidos());
        } else if (dto instanceof RegistroJugadorDTO) {
            usuario.setApellido(((RegistroJugadorDTO) dto).getApellido());
        } else if (dto instanceof RegistroUsuarioDTO) {
            usuario.setApellido(((RegistroUsuarioDTO) dto).getApellido());
        }

        return usuario;
    }

    private void crearEntidadEspecifica(RegistroBaseDTO dto, Usuario usuario) {
        switch (usuario.getRole()) {
            case ENTRENADOR:
                entrenadorService.crearDesdeRegistro((RegisterEntrenadorDTO) dto, usuario);
                break;
            case ARBITRO:
                arbitroService.crearDesdeRegistro((RegistroArbitroDTO) dto, usuario);
                break;
            case JUGADOR:
                jugadorService.crearDesdeRegistro((RegistroJugadorDTO) dto, usuario);
                break;
            case USUARIO:
            case ADMIN:
                log.info("Rol {} no requiere entidad específica", usuario.getRole());
                break;
        }
    }

    private void validarRegistro(RegistroBaseDTO dto) {
        // Validaciones comunes
        if (dto.getEmail() == null || dto.getEmail().isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El email es obligatorio");
        if (dto.getUsername() == null || dto.getUsername().isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El username es obligatorio");
        if (dto.getPassword() == null || dto.getPassword().isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La contraseña es obligatoria");
        if (dto.getRol() == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El rol es obligatorio");

        // Validar unicidad
        if (usuarioRepository.existsByEmail(dto.getEmail()))
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El email ya está registrado");
        if (usuarioRepository.existsByUsername(dto.getUsername()))
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El username ya está en uso");

        // Validaciones específicas por rol (los servicios específicos también validarán)
        if (dto instanceof RegisterEntrenadorDTO) {
            RegisterEntrenadorDTO entDTO = (RegisterEntrenadorDTO) dto;
            if (entDTO.getCodigoEntrenador() == null || entDTO.getCodigoEntrenador().isBlank())
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El código de entrenador es obligatorio");
        } else if (dto instanceof RegistroArbitroDTO) {
            RegistroArbitroDTO arbDTO = (RegistroArbitroDTO) dto;
            if (arbDTO.getCodigoArbitro() == null || arbDTO.getCodigoArbitro().isBlank())
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El código de árbitro es obligatorio");
        } else if (dto instanceof RegistroJugadorDTO) {
            RegistroJugadorDTO jugDTO = (RegistroJugadorDTO) dto;
            if (jugDTO.getCodigoJugador() == null || jugDTO.getCodigoJugador().isBlank())
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El código de jugador es obligatorio");
            if (jugDTO.getPosicion() == null || jugDTO.getPosicion().isBlank())
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La posición es obligatoria");
        }

    }

    // ──────────────────────────────────────────────
    // VERIFICACIÓN DE EMAIL
    // ──────────────────────────────────────────────

    @Transactional
    public LoginResponse verificarCodigo(VerificacionEmailDTO dto) {
        log.info("Verificando código: {}", dto.getCodigo());

        EmailVerification verification = emailVerificationRepository.findByCodigo(dto.getCodigo())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Código inválido"));

        if (verification.getExpirationTime().isBefore(LocalDateTime.now())) {
            emailVerificationRepository.delete(verification);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El código ha expirado");
        }

        if (verification.isVerified()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El código ya fue utilizado");
        }

        // Marcar como verificado
        verification.setVerified(true);
        emailVerificationRepository.save(verification);

        // Buscar y actualizar usuario
        Usuario usuario = usuarioRepository.findByEmail(verification.getEmail());
        if (usuario == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }

        usuario.setVerificado(true);
        usuarioRepository.save(usuario);

        // Notificar a la entidad específica
        notificarVerificacionAEntidad(usuario);

        // Generar tokens
        String token = jwtTokenProvider.generateToken(usuario);
        String refreshToken = jwtTokenProvider.generateRefreshToken(usuario);

        usuario.setToken(token);
        usuario.setRefreshToken(refreshToken);
        usuarioRepository.save(usuario);

        log.info("Usuario verificado correctamente: {}", usuario.getUsername());

        return buildLoginResponse(usuario, token, refreshToken);
    }

    private void notificarVerificacionAEntidad(Usuario usuario) {
        switch (usuario.getRole()) {
            case ENTRENADOR:
                entrenadorService.marcarComoVerificado(usuario.getEmail());
                break;
            case ARBITRO:
                arbitroService.marcarComoVerificado(usuario.getEmail());
                break;
            case JUGADOR:
                jugadorService.marcarComoVerificado(usuario.getEmail());
                break;
            default:
                log.info("Rol {} no requiere notificación de verificación", usuario.getRole());
        }
    }

    @Transactional
    public void reenviarCodigo(String email) {
        Usuario usuario = usuarioRepository.findByEmail(email);

        if (usuario == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Email no encontrado");
        if (usuario.isVerificado())
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El email ya ha sido verificado");

        // Eliminar códigos anteriores
        emailVerificationRepository.findByEmail(email).ifPresent(emailVerificationRepository::delete);

        // Generar nuevo código
        String nuevoCodigo = generarCodigoVerificacion(email);
        enviarCodigoVerificacion(email, nuevoCodigo);

        log.info("Código reenviado a: {}", email);
    }

    private String generarCodigoVerificacion(String email) {
        String codigo = generarCodigo();

        EmailVerification verification = new EmailVerification();
        verification.setEmail(email);
        verification.setCodigo(codigo);
        verification.setExpirationTime(LocalDateTime.now().plusMinutes(10));
        verification.setVerified(false);

        emailVerificationRepository.save(verification);
        return codigo;
    }

    // ──────────────────────────────────────────────
    // AUTENTICACIÓN
    // ──────────────────────────────────────────────

    @Transactional
    public LoginResponse login(LoginRequest dto) {
        Usuario usuario = usuarioRepository.findByUsername(dto.getUsername());

        if (usuario == null)
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenciales incorrectas");
        if (!usuario.isVerificado())
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Cuenta no verificada. Revisa tu email");
        if (usuario.isBloqueado())
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Cuenta bloqueada");
        if (!passwordEncoder.matches(dto.getPassword(), usuario.getPassword()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenciales incorrectas");

        String token = jwtTokenProvider.generateToken(usuario);
        String refreshToken = jwtTokenProvider.generateRefreshToken(usuario);

        usuario.setToken(token);
        usuario.setRefreshToken(refreshToken);
        usuarioRepository.save(usuario);

        return buildLoginResponse(usuario, token, refreshToken);
    }

    @Transactional
    public LoginResponse refreshToken(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Refresh token no proporcionado");

        if (!jwtTokenProvider.validateToken(refreshToken))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token inválido");

        String username = jwtTokenProvider.getUsernameFromToken(refreshToken);
        Usuario usuario = usuarioRepository.findByUsername(username);

        if (usuario == null || !refreshToken.equals(usuario.getRefreshToken()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token no válido");

        String nuevoToken = jwtTokenProvider.generateToken(usuario);
        usuario.setToken(nuevoToken);
        usuarioRepository.save(usuario);

        return buildLoginResponse(usuario, nuevoToken, refreshToken);
    }

    @Transactional
    public void logout(String username) {
        Usuario usuario = usuarioRepository.findByUsername(username);

        if (usuario != null) {
            usuario.setToken(null);
            usuario.setRefreshToken(null);
            usuarioRepository.save(usuario);
            log.info("Usuario {} ha cerrado sesión", username);
        }
    }

    // ──────────────────────────────────────────────
    // PERFIL
    // ──────────────────────────────────────────────

    public UsuarioPerfilDTO obtenerPerfil(String username) {
        Usuario usuario = usuarioRepository.findByUsername(username);

        if (usuario == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");

        return UsuarioPerfilDTO.fromEntity(usuario);
    }

    @Transactional
    public void cambiarPassword(ChangePasswordDTO changePasswordDTO) {
        Usuario usuario = usuarioRepository.findByEmail(changePasswordDTO.getEmail());

        if (usuario == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        if (!passwordEncoder.matches(changePasswordDTO.getPassword(), usuario.getPassword()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Contraseña actual incorrecta");

        usuario.setPassword(passwordEncoder.encode(changePasswordDTO.getNewPassword()));
        usuarioRepository.save(usuario);

        // Actualizar contraseña en entidad específica
        actualizarPasswordEnEntidad(usuario);

        log.info("Contraseña actualizada para usuario: {}" + usuario.getNombre());
    }

    private void actualizarPasswordEnEntidad(Usuario usuario) {
        switch (usuario.getRole()) {
            case ENTRENADOR:
                entrenadorService.actualizarPassword(usuario.getEmail(), usuario.getPassword());
                break;
            case ARBITRO:
                arbitroService.actualizarPassword(usuario.getEmail(), usuario.getPassword());
                break;
            case JUGADOR:
                jugadorService.actualizarPassword(usuario.getEmail(), usuario.getPassword());
                break;
        }
    }

    // ──────────────────────────────────────────────
    // MÉTODOS PRIVADOS
    // ──────────────────────────────────────────────

    private String generarCodigo() {
        return String.valueOf(100000 + new SecureRandom().nextInt(900000));
    }

    private void enviarCodigoVerificacion(String email, String codigo) {
        try {
            emailService.enviarCodigoVerificacion(email, codigo);
        } catch (MessagingException e) {
            log.error("Error enviando email a {}: {}", email, e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "No se pudo enviar el email de verificación");
        }
    }

    private LoginResponse buildLoginResponse(Usuario usuario, String token, String refreshToken) {
        LoginResponse response = new LoginResponse();
        response.setToken(token);
        response.setRefreshToken(refreshToken);
        response.setUsername(usuario.getUsername());
        response.setNombre(usuario.getNombre());
        response.setApellido(usuario.getApellido());
        response.setEmail(usuario.getEmail());
        response.setRol(usuario.getRole().name());
        return response;
    }

    private Long obtenerEntidadId(Usuario usuario) {
        switch (usuario.getRole()) {
            case ENTRENADOR:
                return entrenadorService.obtenerIdPorEmail(usuario.getEmail());
            case ARBITRO:
                return arbitroService.obtenerIdPorEmail(usuario.getEmail());
            case JUGADOR:
                return jugadorService.obtenerIdPorEmail(usuario.getEmail());
            default:
                return null;
        }
    }


    public SeguirReponseDTO seguirJugador(Long idJugador, Usuario usuario) {
        Jugador jugador = jugadorRepository.findById(idJugador)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Jugador no encontrado"));

        SeguirReponseDTO seguir = new SeguirReponseDTO();
        seguir.setNombreJugador(jugador.getNombre());
        seguir.setPosicion(jugador.getPosicion());
        seguir.setNombreEquipoJugador(
                jugador.getEquipo() != null ? jugador.getEquipo().getNombre() : "Sin equipo");

        if (!usuario.getListaJugadorSiguiendo().contains(jugador)) {
            usuario.getListaJugadorSiguiendo().add(jugador);
            usuarioRepository.save(usuario);
        }

        return seguir;
    }


    public SeguirEquipoDTO seguirEquipo(Long idEquipo, Usuario usuario) {
        Equipo equipo = equipoRepository.findById(idEquipo)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Equipo no encontrado"));

        SeguirEquipoDTO seguir = new SeguirEquipoDTO();
        seguir.setNombreEquipo(equipo.getNombre());
        seguir.setNombreLiga(equipo.getLiga().getNombreLiga());

        if (!usuario.getListaEquiposSiguiendo().contains(equipo)) {
            usuario.getListaEquiposSiguiendo().add(equipo);
            usuarioRepository.save(usuario);
        }

        return seguir;
    }




}