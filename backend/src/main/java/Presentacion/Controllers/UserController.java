package Presentacion.Controllers;

import Aplicacion.Services.UserService;
import Dominio.Entity.Roles.Roles;
import Dominio.Entity.Usuario;
import Presentacion.Config.JwtTokenProvider;
import Presentacion.DTOS.Usuarios.ActualizarUsuarioDTO;
import Presentacion.DTOS.Usuarios.Login.LoginRequest;
import Presentacion.DTOS.Usuarios.Login.LoginResponse;
import Presentacion.DTOS.Usuarios.Register.*;
import Presentacion.DTOS.Usuarios.UsuarioPerfilDTO;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody Map<String, Object> payload) {
        log.info("========================================");
        log.info(" Registro - Payload recibido: {}", payload);

        String rolStr = (String) payload.get("rol");
        log.info(" Rol detectado: {}", rolStr);

        RegistroBaseDTO dto = null;

        switch (rolStr) {
            case "ADMIN":
                log.info(" Creando DTO para ADMIN");
                RegistroAdminDTO adminDTO = new RegistroAdminDTO();
                String adminKey = (String) payload.get("adminKey");
                log.info(" Clave de admin recibida: {}", adminKey);
                adminDTO.setAdminKey(adminKey);
                adminDTO.setApellido((String) payload.get("apellido"));
                dto = adminDTO;
                break;
            case "ENTRENADOR":
                log.info(" Creando DTO para ENTRENADOR");
                RegisterEntrenadorDTO entDTO = new RegisterEntrenadorDTO();
                entDTO.setCodigoEntrenador((String) payload.get("codigoEntrenador"));
                entDTO.setApellido((String) payload.get("apellido"));
                dto = entDTO;
                break;
            case "JUGADOR":
                log.info(" Creando DTO para JUGADOR");
                RegistroJugadorDTO jugDTO = new RegistroJugadorDTO();
                jugDTO.setCodigoJugador((String) payload.get("codigoJugador"));
                jugDTO.setPosicion((String) payload.get("posicion"));
                jugDTO.setApellido((String) payload.get("apellido"));
                dto = jugDTO;
                break;
            case "ARBITRO":
                log.info(" Creando DTO para ARBITRO");
                RegistroArbitroDTO arbDTO = new RegistroArbitroDTO();
                arbDTO.setCodigoArbitro((String) payload.get("codigoArbitro"));
                arbDTO.setApellidos((String) payload.get("apellido"));

                dto = arbDTO;
                break;
            default:
                log.info(" Creando DTO para USUARIO normal");
                RegistroUsuarioDTO userDTO = new RegistroUsuarioDTO();
                userDTO.setApellido((String) payload.get("apellido"));
                dto = userDTO;
                break;
        }

        dto.setEmail((String) payload.get("email"));
        dto.setUsername((String) payload.get("username"));
        dto.setNombre((String) payload.get("nombre"));
        dto.setEdad((Integer) payload.get("edad"));
        dto.setPassword((String) payload.get("password"));

        log.info(" Registrando usuario: {} con rol: {}", dto.getUsername(), dto.getRol());

        userService.registrarInicial(dto);

        log.info(" Registro exitoso para: {}", dto.getUsername());
        log.info("========================================");

        return ResponseEntity.ok().build();
    }

    @PostMapping("/verificar")
    public ResponseEntity<?> verificarCodigo(@RequestBody Map<String, String> request) {
        log.info("========================================");
        log.info(" INICIANDO VERIFICACIÓN DE CÓDIGO");
        log.info("   Email: {}", request.get("email"));
        log.info("   Código: {}", request.get("codigo"));

        String email = request.get("email");
        String codigo = request.get("codigo");

        if (email == null || email.isEmpty()) {
            log.error(" Email no proporcionado");
            return ResponseEntity.badRequest().body(Map.of("error", "Email requerido"));
        }

        if (codigo == null || codigo.isEmpty()) {
            log.error(" Código no proporcionado");
            return ResponseEntity.badRequest().body(Map.of("error", "Código requerido"));
        }

        try {

            boolean verificado = userService.verificarCodigo(email, codigo);

            if (verificado) {
                log.info(" Código verificado exitosamente para: {}", email);

                Usuario usuario = userService.findByEmail(email);
                if (usuario == null) {
                    log.error(" Usuario no encontrado después de verificación: {}", email);
                    return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
                }

                log.info(" Usuario encontrado: {}", usuario.getUsername());
                log.info(" Rol del usuario: {}", usuario.getRole());

                String token = jwtTokenProvider.generateToken(usuario);
                String refreshToken = jwtTokenProvider.generateRefreshToken(usuario);

                log.info(" Tokens generados para: {}", usuario.getUsername());

                userService.actualizarRefreshToken(usuario.getUsername(), refreshToken);

                LoginResponse response = LoginResponse.builder()
                        .token(token)
                        .refreshToken(refreshToken)
                        .username(usuario.getUsername())
                        .email(usuario.getEmail())
                        .rol(usuario.getRole().name())
                        .verificado(true)
                        .build();

                log.info(" Verificación completada exitosamente para: {}", email);
                log.info("========================================");

                return ResponseEntity.ok(response);
            } else {
                log.warn(" Código de verificación inválido o expirado para: {}", email);
                log.info("========================================");
                return ResponseEntity.status(401).body(Map.of(
                        "error", "Código inválido o expirado",
                        "message", "El código de verificación no es correcto o ha expirado"
                ));
            }
        } catch (Exception e) {
            log.error(" Error durante la verificación: {}", e.getMessage(), e);
            log.info("========================================");
            return ResponseEntity.status(500).body(Map.of(
                    "error", "Error interno",
                    "message", e.getMessage()
            ));
        }
    }

    @PostMapping("/logout")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> logout(HttpServletRequest request) {
        try {
            String token = jwtTokenProvider.getTokenFromRequest(request);
            if (token != null && jwtTokenProvider.validateToken(token)) {
                String username = jwtTokenProvider.getUsernameFromToken(token);
                log.info("Usuario cerró sesión: {}", username);
                userService.actualizarRefreshToken(username, null);
            }
            return ResponseEntity.ok(Map.of("message", "Logout exitoso"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error al cerrar sesión: " + e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        log.info("========================================");
        log.info(" Intento login para: {}", loginRequest.getUsername());

        try {

            Usuario usuario = userService.findByUsername(loginRequest.getUsername());
            if (usuario == null) {
                log.error(" Usuario no encontrado: {}", loginRequest.getUsername());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Usuario no encontrado");
                error.put("message", "Las credenciales son incorrectas");
                return ResponseEntity.status(401).body(error);
            }

            // Comprobar bloqueo antes que nada
            if (usuario.isBloqueado()) {
                log.error(" Usuario bloqueado: {}", loginRequest.getUsername());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Usuario bloqueado");
                error.put("message", "Tu cuenta ha sido bloqueada tras demasiados intentos fallidos. Contacta con soporte.");
                return ResponseEntity.status(403).body(error);
            }

            boolean passwordMatches = passwordEncoder.matches(loginRequest.getPassword(), usuario.getPassword());

            if (!passwordMatches) {
                int intentos = usuario.getIntentosFallidos() + 1;
                usuario.setIntentosFallidos(intentos);
                if (intentos >= 5) {
                    usuario.setBloqueado(true);
                    log.warn(" Cuenta bloqueada por {} intentos fallidos: {}", intentos, loginRequest.getUsername());
                } else {
                    log.warn(" Contraseña incorrecta para: {} ({}/5 intentos)", loginRequest.getUsername(), intentos);
                }
                userService.guardarUsuario(usuario);
                Map<String, String> error = new HashMap<>();
                error.put("error", "Credenciales incorrectas");
                error.put("message", intentos >= 5
                        ? "Cuenta bloqueada tras 5 intentos fallidos. Contacta con soporte."
                        : "Las credenciales son incorrectas (" + intentos + "/5 intentos)");
                return ResponseEntity.status(401).body(error);
            }

            if (!usuario.isVerificado() && usuario.getRole() != Roles.ADMIN) {
                log.warn(" Usuario no verificado: {}", loginRequest.getUsername());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Usuario no verificado");
                error.put("message", "Por favor, verifica tu cuenta con el código enviado a tu email");
                return ResponseEntity.status(403).body(error);
            }

            // Login correcto: resetear intentos fallidos
            usuario.setIntentosFallidos(0);
            userService.guardarUsuario(usuario);

            String token = jwtTokenProvider.generateToken(usuario);
            String refreshToken = jwtTokenProvider.generateRefreshToken(usuario);

            log.info(" Token generado para: {}", usuario.getUsername());

            userService.actualizarRefreshToken(usuario.getUsername(), refreshToken);

            LoginResponse loginResponse = LoginResponse.builder()
                    .token(token)
                    .refreshToken(refreshToken)
                    .username(usuario.getUsername())
                    .email(usuario.getEmail())
                    .rol(usuario.getRole().name())
                    .build();

            log.info(" Login exitoso para: {}", usuario.getUsername());
            log.info("========================================");

            return ResponseEntity.ok(loginResponse);

        } catch (Exception e) {
            log.error(" Error inesperado en login: ", e);
            Map<String, String> error = new HashMap<>();
            error.put("error", "Error interno del servidor");
            error.put("message", "Ocurrió un error al procesar el login");
            return ResponseEntity.status(500).body(error);
        }
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        log.info(" Refrescando token");

        if (refreshToken == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Refresh token requerido"));
        }

        try {
            String username = jwtTokenProvider.getUsernameFromToken(refreshToken);
            if (username == null) {
                return ResponseEntity.status(401).body(Map.of("error", "Refresh token inválido"));
            }

            Usuario usuario = userService.findByUsername(username);
            if (usuario == null || !refreshToken.equals(usuario.getRefreshToken())) {
                return ResponseEntity.status(401).body(Map.of("error", "Refresh token inválido"));
            }

            if (!jwtTokenProvider.validateToken(refreshToken)) {
                return ResponseEntity.status(401).body(Map.of("error", "Refresh token expirado"));
            }

            String newToken = jwtTokenProvider.generateToken(usuario);
            String newRefreshToken = jwtTokenProvider.generateRefreshToken(usuario);
            userService.actualizarRefreshToken(username, newRefreshToken);

            Map<String, String> response = new HashMap<>();
            response.put("token", newToken);
            response.put("refreshToken", newRefreshToken);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error refrescando token: ", e);
            return ResponseEntity.status(500).body(Map.of("error", "Error al refrescar token"));
        }
    }

    @PutMapping("/actualizar")
    public ResponseEntity<UsuarioPerfilDTO> actualizarUser(
            HttpServletRequest request,
            @RequestBody ActualizarUsuarioDTO actualizarUsuarioDTO) {

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        String token = authHeader.substring(7);
        String username = jwtTokenProvider.getUsernameFromToken(token);

        log.info(" Actualizando perfil para usuario: {}", username);

        return ResponseEntity.ok(userService.actualizarPerfilPorUsername(username, actualizarUsuarioDTO));
    }

    @GetMapping("/perfil/{username}")
    public ResponseEntity<UsuarioPerfilDTO> obtenerPerfil(@PathVariable String username) {
        log.info(" Obteniendo perfil para: {}", username);
        UsuarioPerfilDTO perfil = userService.obtenerPerfilPorUsername(username);
        return ResponseEntity.ok(perfil);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isBlank())
            return ResponseEntity.badRequest().body(Map.of("error", "Email requerido"));
        try {
            userService.solicitarRecuperacionContrasena(email);
            return ResponseEntity.ok(Map.of("message", "Código de recuperación enviado a tu email"));
        } catch (Exception e) {
            log.error("Error en forgot-password: {}", e.getMessage());
            return ResponseEntity.status(404).body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String codigo = request.get("codigo");
        String nuevaPassword = request.get("nuevaPassword");
        if (email == null || codigo == null || nuevaPassword == null)
            return ResponseEntity.badRequest().body(Map.of("error", "Email, código y nueva contraseña son obligatorios"));
        try {
            userService.restablecerContrasena(email, codigo, nuevaPassword);
            return ResponseEntity.ok(Map.of("message", "Contraseña restablecida correctamente"));
        } catch (Exception e) {
            log.error("Error en reset-password: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

}
