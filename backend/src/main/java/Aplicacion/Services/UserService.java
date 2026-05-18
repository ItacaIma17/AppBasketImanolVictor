package Aplicacion.Services;

import Dominio.Entity.*;
import Dominio.Entity.Roles.Roles;
import Dominio.Repositorys.*;
import Presentacion.Config.JwtTokenProvider;
import Presentacion.DTOS.Equipo.SeguirEquipoDTO;
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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

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
    private final EntrenadorRepository entrenadorRepository;
    private final EquipoRepository equipoRepository;

    private final JwtTokenProvider jwtTokenProvider;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    private final CustomUserDetailsService userDetails;

    @Value("${admin.secret.key:ADMIN_SECRET_KEY_2024}")
    private String adminSecretKey;

    @Transactional
    public void registrarInicial(RegistroBaseDTO dto) {
        log.info("========================================");
        log.info(" Iniciando registro para usuario: {}", dto.getUsername());
        log.info(" Rol solicitado: {}", dto.getRol());

        boolean isAdmin = dto.getRol() == Roles.ADMIN;
        if (isAdmin) {
            log.info(" Procesando registro de ADMINISTRADOR");
            String adminKey = null;
            if (dto instanceof RegistroAdminDTO) {
                adminKey = ((RegistroAdminDTO) dto).getAdminKey();
            }
            log.info(" Clave de admin recibida: {}", adminKey);

            if (adminKey == null || adminKey.isEmpty()) {
                log.error(" Clave de administrador no proporcionada");
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "La clave de administrador es obligatoria");
            }

            if (!adminSecretKey.equals(adminKey)) {
                log.error(" Clave de administrador INCORRECTA");
                throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                        "Clave de administrador incorrecta");
            }
            log.info(" Clave de administrador CORRECTA");
        }

        validarRegistro(dto);

        Usuario usuario = crearUsuarioBase(dto);

        if (isAdmin) {
            usuario.setVerificado(true);
            log.info(" Administrador creado como VERIFICADO automáticamente");
        }

        usuarioRepository.save(usuario);
        log.info(" Usuario base creado con ID: {}", usuario.getId());

        crearEntidadEspecifica(dto, usuario);

        if (!isAdmin) {
            String codigo = generarCodigoVerificacion(dto.getEmail());
            enviarCodigoVerificacion(dto.getEmail(), codigo);
            log.info(" Código de verificación enviado a: {}", dto.getEmail());
        } else {
            log.info(" Administrador registrado sin necesidad de verificación por email");
        }

        log.info(" Registro COMPLETADO para: {}", dto.getEmail());
        log.info("========================================");
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

        if (dto instanceof RegisterEntrenadorDTO) {
            usuario.setApellido(((RegisterEntrenadorDTO) dto).getApellido());
        } else if (dto instanceof RegistroArbitroDTO) {
            usuario.setApellido(((RegistroArbitroDTO) dto).getApellidos());
        } else if (dto instanceof RegistroJugadorDTO) {
            usuario.setApellido(((RegistroJugadorDTO) dto).getApellido());
        } else if (dto instanceof RegistroUsuarioDTO) {
            usuario.setApellido(((RegistroUsuarioDTO) dto).getApellido());
        } else if (dto instanceof RegistroAdminDTO) {
            usuario.setApellido(((RegistroAdminDTO) dto).getApellido());
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

        if (dto.getEmail() == null || dto.getEmail().isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El email es obligatorio");
        if (dto.getUsername() == null || dto.getUsername().isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El username es obligatorio");
        if (dto.getPassword() == null || dto.getPassword().isBlank())
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La contraseña es obligatoria");
        if (dto.getRol() == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El rol es obligatorio");

        if (usuarioRepository.existsByEmail(dto.getEmail()))
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El email ya está registrado");
        if (usuarioRepository.existsByUsername(dto.getUsername()))
            throw new ResponseStatusException(HttpStatus.CONFLICT, "El username ya está en uso");

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

    @Transactional
    public UsuarioPerfilDTO actualizarPerfil(UserDetails userDetails, ActualizarUsuarioDTO dto) {
        Usuario usuario = usuarioRepository.findByUsername(userDetails.getUsername());

        if (usuario == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }

        if (dto.getUsername() != null && !dto.getUsername().isEmpty()) {
            if (!dto.getUsername().equals(usuario.getUsername()) &&
                    usuarioRepository.existsByUsername(dto.getUsername())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "El nombre de usuario ya está en uso");
            }
            usuario.setUsername(dto.getUsername());
            log.info("Username actualizado de {} a {}", userDetails.getUsername(), dto.getUsername());
        }

        if (dto.getOldPassword() != null && !dto.getOldPassword().isEmpty() &&
                dto.getNewPassword() != null && !dto.getNewPassword().isEmpty()) {

            if (!passwordEncoder.matches(dto.getOldPassword(), usuario.getPassword())) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Contraseña actual incorrecta");
            }

            if (dto.getNewPassword().length() < 6) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La nueva contraseña debe tener al menos 6 caracteres");
            }

            usuario.setPassword(passwordEncoder.encode(dto.getNewPassword()));
            log.info("Contraseña actualizada para usuario: {}", usuario.getUsername());

            actualizarPasswordEnEntidad(usuario);
        }

        usuario = usuarioRepository.save(usuario);
        log.info("Perfil actualizado para usuario: {}", usuario.getUsername());

        return UsuarioPerfilDTO.fromEntity(usuario);
    }

    @Transactional
    public UsuarioPerfilDTO actualizarPerfilPorUsername(String username, ActualizarUsuarioDTO dto) {
        Usuario usuario = usuarioRepository.findByUsername(username);

        if (usuario == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");
        }

        if (dto.getUsername() != null && !dto.getUsername().isEmpty()) {
            if (!dto.getUsername().equals(usuario.getUsername()) &&
                    usuarioRepository.existsByUsername(dto.getUsername())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "El nombre de usuario ya está en uso");
            }
            usuario.setUsername(dto.getUsername());
            log.info("Username actualizado de {} a {}", username, dto.getUsername());
        }

        if (dto.getNombre() != null && !dto.getNombre().isBlank()) {
            usuario.setNombre(dto.getNombre());
        }

        if (dto.getApellido() != null && !dto.getApellido().isBlank()) {
            usuario.setApellido(dto.getApellido());
        }

        if (dto.getEdad() != null && dto.getEdad() > 0) {
            usuario.setEdad(dto.getEdad());
        }

        if (dto.getOldPassword() != null && !dto.getOldPassword().isEmpty() &&
                dto.getNewPassword() != null && !dto.getNewPassword().isEmpty()) {

            if (!passwordEncoder.matches(dto.getOldPassword(), usuario.getPassword())) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Contraseña actual incorrecta");
            }

            if (dto.getNewPassword().length() < 6) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "La nueva contraseña debe tener al menos 6 caracteres");
            }

            usuario.setPassword(passwordEncoder.encode(dto.getNewPassword()));
            log.info("Contraseña actualizada para usuario: {}", usuario.getUsername());

            actualizarPasswordEnEntidad(usuario);
        }

        usuario = usuarioRepository.save(usuario);
        log.info("Perfil actualizado para usuario: {}", usuario.getUsername());

        return UsuarioPerfilDTO.fromEntity(usuario);
    }

    public void verificarAdministrador() {

        List<Usuario> admins = usuarioRepository.findByRole(Roles.ADMIN);

        if (admins != null && !admins.isEmpty()) {

            Usuario admin = admins.get(0);
            log.info("========================================");
            log.info(" ADMINISTRADOR ENCONTRADO:");
            log.info("   ID: {}", admin.getId());
            log.info("   Username: {}", admin.getUsername());
            log.info("   Email: {}", admin.getEmail());
            log.info("   Nombre: {} {}", admin.getNombre(), admin.getApellido());
            log.info("   Rol: {}", admin.getRole());
            log.info("   Verificado: {}", admin.isVerificado());
            log.info("   Bloqueado: {}", admin.isBloqueado());

            if (admins.size() > 1) {
                log.warn(" Hay {} administradores en el sistema", admins.size());
            }
            log.info("========================================");
        } else {
            log.warn("========================================");
            log.warn(" No se encontró ningún administrador en el sistema");
            log.warn(" Se creará automáticamente en el próximo inicio");
            log.warn("========================================");
        }
    }

    @Transactional
    public boolean verificarCodigo(String email, String codigo) {
        log.info(" Verificando código para email: {}", email);
        log.info("   Código proporcionado: {}", codigo);

        EmailVerification verification = emailVerificationRepository
                .findByEmail(email)
                .orElse(null);

        if (verification == null) {
            log.error(" No se encontró verificación pendiente para: {}", email);
            return false;
        }

        log.info(" Verificación encontrada:");
        log.info("   Código almacenado: {}", verification.getCodigo());
        log.info("   Fecha expiración: {}", verification.getExpirationTime());
        log.info("   Ya verificado: {}", verification.isVerified());

        if (verification.isVerified()) {
            log.warn(" El usuario ya estaba verificado: {}", email);
            return true;
        }

        if (verification.getExpirationTime().isBefore(LocalDateTime.now())) {
            log.warn(" El código ha expirado para: {}", email);
            log.warn("   Expiró en: {}", verification.getExpirationTime());
            return false;
        }

        if (!verification.getCodigo().equals(codigo)) {
            log.warn(" Código incorrecto para: {}", email);
            log.warn("   Esperado: {}", verification.getCodigo());
            log.warn("   Recibido: {}", codigo);
            return false;
        }

        log.info(" Código correcto, marcando como verificado...");

        verification.setVerified(true);
        emailVerificationRepository.save(verification);

        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario != null) {
            usuario.setVerificado(true);
            usuarioRepository.save(usuario);
            log.info(" Usuario marcado como verificado: {}", usuario.getUsername());

            if (usuario.getRole() == Roles.ENTRENADOR) {
                entrenadorRepository.findById(usuario.getId())
                        .ifPresent(entrenador -> {
                            entrenador.setVerificado(true);
                            entrenadorRepository.save(entrenador);
                            log.info(" Entrenador marcado como verificado: {}", entrenador.getNombre());
                        });
            }
        }

        log.info(" Verificación completada exitosamente para: {}", email);
        return true;
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

        emailVerificationRepository.findByEmail(email).ifPresent(emailVerificationRepository::delete);

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

    @Transactional
    public void login(LoginRequest dto) {
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

    }

    @Transactional
    public LoginResponse refreshToken(String refreshToken) {

        if (refreshToken == null || refreshToken.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Refresh token no proporcionado");
        }

        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token inválido");
        }

        String username = jwtTokenProvider.getUsernameFromToken(refreshToken);

        Usuario usuario = usuarioRepository.findByUsername(username);

        if (usuario == null || !refreshToken.equals(usuario.getRefreshToken())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token no válido");
        }

        String newToken = jwtTokenProvider.generateToken(usuario);
        String newRefresh = jwtTokenProvider.generateRefreshToken(usuario);

        usuario.setToken(newToken);
        usuario.setRefreshToken(newRefresh);
        usuarioRepository.save(usuario);

        return buildLoginResponse(usuario, newToken, newRefresh);
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

        actualizarPasswordEnEntidad(usuario);

        log.info("Contraseña actualizada para usuario: {}", usuario.getNombre());
    }

    private void actualizarPasswordEnEntidad(Usuario usuario) {
        String email = usuario.getEmail();
        String passwordEncriptada = usuario.getPassword();

        switch (usuario.getRole()) {
            case ENTRENADOR:
                entrenadorService.actualizarPassword(email, passwordEncriptada);
                break;
            case ARBITRO:
                arbitroService.actualizarPassword(email, passwordEncriptada);
                break;
            case JUGADOR:
                jugadorService.actualizarPassword(email, passwordEncriptada);
                break;
            case USUARIO:
            case ADMIN:
                log.info("Rol {} no requiere actualizar contraseña en entidad específica", usuario.getRole());
                break;
        }
    }

    @Transactional
    public void solicitarRecuperacionContrasena(String email) {
        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No existe ninguna cuenta con ese email");

        emailVerificationRepository.findByEmail("reset_" + email)
                .ifPresent(emailVerificationRepository::delete);

        String codigo = generarCodigo();
        EmailVerification reset = new EmailVerification();
        reset.setEmail("reset_" + email);
        reset.setCodigo(codigo);
        reset.setExpirationTime(LocalDateTime.now().plusMinutes(15));
        reset.setVerified(false);
        emailVerificationRepository.save(reset);

        try {
            emailService.enviarRecuperacionContrasena(email, usuario.getNombre(), codigo);
        } catch (Exception e) {
            log.error("Error enviando email de recuperación a {}: {}", email, e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "No se pudo enviar el email de recuperación");
        }
        log.info("Código de recuperación enviado a: {}", email);
    }

    @Transactional
    public void restablecerContrasena(String email, String codigo, String nuevaPassword) {
        EmailVerification reset = emailVerificationRepository
                .findByEmail("reset_" + email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "No hay ninguna solicitud de recuperación para este email"));

        if (reset.getExpirationTime().isBefore(LocalDateTime.now()))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "El código ha expirado");

        if (!reset.getCodigo().equals(codigo))
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Código incorrecto");

        if (nuevaPassword == null || nuevaPassword.length() < 6)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "La contraseña debe tener al menos 6 caracteres");

        Usuario usuario = usuarioRepository.findByEmail(email);
        if (usuario == null)
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado");

        usuario.setPassword(passwordEncoder.encode(nuevaPassword));
        usuarioRepository.save(usuario);
        actualizarPasswordEnEntidad(usuario);
        emailVerificationRepository.delete(reset);
        log.info("Contraseña restablecida para: {}", email);
    }

    public Usuario findByUsername(String username) {
        log.info(" Buscando usuario por username: {}", username);
        return usuarioRepository.findByUsername(username);
    }

    public Usuario findByEmail(String email) {
        log.info(" Buscando usuario por email: {}", email);
        return usuarioRepository.findByEmail(email);
    }

    public void actualizarRefreshToken(String username, String refreshToken) {
        log.info(" Actualizando refresh token para: {}", username);
        Usuario usuario = findByUsername(username);
        if (usuario != null) {
            usuario.setRefreshToken(refreshToken);
            usuarioRepository.save(usuario);
            log.info(" Refresh token actualizado");
        }
    }

    public UsuarioPerfilDTO obtenerPerfilPorUsername(String username) {
        log.info(" Obteniendo perfil para: {}", username);
        Usuario usuario = findByUsername(username);
        if (usuario == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado: " + username);
        }

        return UsuarioPerfilDTO.builder()
                .username(usuario.getUsername())
                .email(usuario.getEmail())
                .nombre(usuario.getNombre())
                .apellido(usuario.getApellido())
                .edad(usuario.getEdad())
                .rol(usuario.getRole())
                .verificado(usuario.isVerificado())
                .build();
    }

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
        LoginResponse response = LoginResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .username(usuario.getUsername())
                .email(usuario.getEmail())
                .rol(usuario.getRole().name())
                .build();
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
