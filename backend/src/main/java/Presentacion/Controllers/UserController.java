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
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
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
    private final AuthenticationManager authenticationManager;  // ← Añadir esto
    private final PasswordEncoder passwordEncoder;              // ← Añadir esto

    // Presentacion/Controllers/UserController.java

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody Map<String, Object> payload) {
        log.info("========================================");
        log.info("📦 Registro - Payload recibido: {}", payload);

        String rolStr = (String) payload.get("rol");
        log.info("🔍 Rol detectado: {}", rolStr);

        RegistroBaseDTO dto = null;

        switch (rolStr) {
            case "ADMIN":
                log.info("👑 Creando DTO para ADMIN");
                RegistroAdminDTO adminDTO = new RegistroAdminDTO();
                String adminKey = (String) payload.get("adminKey");
                log.info("🔑 Clave de admin recibida: {}", adminKey);
                adminDTO.setAdminKey(adminKey);
                adminDTO.setApellido((String) payload.get("apellido"));
                dto = adminDTO;
                break;
            case "ENTRENADOR":
                log.info("🏆 Creando DTO para ENTRENADOR");
                RegisterEntrenadorDTO entDTO = new RegisterEntrenadorDTO();
                entDTO.setCodigoEntrenador((String) payload.get("codigoEntrenador"));
                entDTO.setApellido((String) payload.get("apellido"));
                dto = entDTO;
                break;
            case "JUGADOR":
                log.info("🏀 Creando DTO para JUGADOR");
                RegistroJugadorDTO jugDTO = new RegistroJugadorDTO();
                jugDTO.setCodigoJugador((String) payload.get("codigoJugador"));
                jugDTO.setPosicion((String) payload.get("posicion"));
                jugDTO.setApellido((String) payload.get("apellido"));
                dto = jugDTO;
                break;
            case "ARBITRO":
                log.info("⚖️ Creando DTO para ARBITRO");
                RegistroArbitroDTO arbDTO = new RegistroArbitroDTO();
                arbDTO.setCodigoArbitro((String) payload.get("codigoArbitro"));
                arbDTO.setApellidos((String) payload.get("apellido"));
                // ✅ NO se necesita adminKey para árbitro
                dto = arbDTO;
                break;
            default:
                log.info("👤 Creando DTO para USUARIO normal");
                RegistroUsuarioDTO userDTO = new RegistroUsuarioDTO();
                userDTO.setApellido((String) payload.get("apellido"));
                dto = userDTO;
                break;
        }

        // Campos comunes
        dto.setEmail((String) payload.get("email"));
        dto.setUsername((String) payload.get("username"));
        dto.setNombre((String) payload.get("nombre"));
        dto.setEdad((Integer) payload.get("edad"));
        dto.setPassword((String) payload.get("password"));

        log.info("📝 Registrando usuario: {} con rol: {}", dto.getUsername(), dto.getRol());

        // ✅ Registrar sin necesidad de clave de admin (la validación está dentro de registrarInicial)
        userService.registrarInicial(dto);

        log.info("✅ Registro exitoso para: {}", dto.getUsername());
        log.info("========================================");

        return ResponseEntity.ok().build();
    }


    @PostMapping("/verificar")
    public ResponseEntity<?> verificarCodigo(@RequestBody Map<String, String> request) {
        log.info("========================================");
        log.info("📧 INICIANDO VERIFICACIÓN DE CÓDIGO");
        log.info("   Email: {}", request.get("email"));
        log.info("   Código: {}", request.get("codigo"));

        String email = request.get("email");
        String codigo = request.get("codigo");

        if (email == null || email.isEmpty()) {
            log.error("❌ Email no proporcionado");
            return ResponseEntity.badRequest().body(Map.of("error", "Email requerido"));
        }

        if (codigo == null || codigo.isEmpty()) {
            log.error("❌ Código no proporcionado");
            return ResponseEntity.badRequest().body(Map.of("error", "Código requerido"));
        }

        try {
            // Verificar el código
            boolean verificado = userService.verificarCodigo(email, codigo);

            if (verificado) {
                log.info("✅ Código verificado exitosamente para: {}", email);

                // Obtener el usuario
                Usuario usuario = userService.findByEmail(email);
                if (usuario == null) {
                    log.error("❌ Usuario no encontrado después de verificación: {}", email);
                    return ResponseEntity.status(404).body(Map.of("error", "Usuario no encontrado"));
                }

                log.info("👤 Usuario encontrado: {}", usuario.getUsername());
                log.info("🎭 Rol del usuario: {}", usuario.getRole());

                // Generar tokens
                String token = jwtTokenProvider.generateToken(usuario);
                String refreshToken = jwtTokenProvider.generateRefreshToken(usuario);

                log.info("🔑 Tokens generados para: {}", usuario.getUsername());

                // Actualizar refresh token en BD
                userService.actualizarRefreshToken(usuario.getUsername(), refreshToken);

                // Construir respuesta
                LoginResponse response = LoginResponse.builder()
                        .token(token)
                        .refreshToken(refreshToken)
                        .username(usuario.getUsername())
                        .email(usuario.getEmail())
                        .rol(usuario.getRole().name())
                        .verificado(true)
                        .build();

                log.info("✅ Verificación completada exitosamente para: {}", email);
                log.info("========================================");

                return ResponseEntity.ok(response);
            } else {
                log.warn("⚠️ Código de verificación inválido o expirado para: {}", email);
                log.info("========================================");
                return ResponseEntity.status(401).body(Map.of(
                        "error", "Código inválido o expirado",
                        "message", "El código de verificación no es correcto o ha expirado"
                ));
            }
        } catch (Exception e) {
            log.error("❌ Error durante la verificación: {}", e.getMessage(), e);
            log.info("========================================");
            return ResponseEntity.status(500).body(Map.of(
                    "error", "Error interno",
                    "message", e.getMessage()
            ));
        }
    }


    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        log.info("========================================");
        log.info("🔐 Intento login para: {}", loginRequest.getUsername());
        log.info("🔐 Password recibida: {}", loginRequest.getPassword());

        try {
            // 1. Verificar que el usuario existe
            Usuario usuario = userService.findByUsername(loginRequest.getUsername());
            if (usuario == null) {
                log.error("❌ Usuario no encontrado: {}", loginRequest.getUsername());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Usuario no encontrado");
                error.put("message", "Las credenciales son incorrectas");
                return ResponseEntity.status(401).body(error);
            }

            log.info("✅ Usuario encontrado: {}", usuario.getUsername());
            log.info("📧 Email: {}", usuario.getEmail());
            log.info("👑 Rol: {}", usuario.getRole());
            log.info("✅ Verificado: {}", usuario.isVerificado());
            log.info("🔒 Bloqueado: {}", usuario.isBloqueado());
            log.info("🔐 Password hash en BD: {}", usuario.getPassword());

            // 2. Verificar la contraseña manualmente (debug)
            boolean passwordMatches = passwordEncoder.matches(loginRequest.getPassword(), usuario.getPassword());
            log.info("🔐 ¿Coinciden las contraseñas? {}", passwordMatches);

            if (!passwordMatches) {
                log.error("❌ Contraseña incorrecta para: {}", loginRequest.getUsername());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Contraseña incorrecta");
                error.put("message", "Las credenciales son incorrectas");
                return ResponseEntity.status(401).body(error);
            }

            // 3. Verificar si el usuario está bloqueado
            if (usuario.isBloqueado()) {
                log.error("❌ Usuario bloqueado: {}", loginRequest.getUsername());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Usuario bloqueado");
                error.put("message", "Tu cuenta ha sido bloqueada. Contacta con soporte.");
                return ResponseEntity.status(403).body(error);
            }

            // 4. Verificar si el usuario está verificado (excepto ADMIN)
            if (!usuario.isVerificado() && usuario.getRole() != Roles.ADMIN) {
                log.warn("⚠️ Usuario no verificado: {}", loginRequest.getUsername());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Usuario no verificado");
                error.put("message", "Por favor, verifica tu cuenta con el código enviado a tu email");
                return ResponseEntity.status(403).body(error);
            }

            // 5. Autenticar con Spring Security
            try {
                Authentication authentication = authenticationManager.authenticate(
                        new UsernamePasswordAuthenticationToken(
                                loginRequest.getUsername(),
                                loginRequest.getPassword()
                        )
                );
                log.info("✅ Autenticación Spring Security exitosa");
            } catch (AuthenticationException e) {
                log.error("❌ Falló autenticación Spring Security: {}", e.getMessage());
                Map<String, String> error = new HashMap<>();
                error.put("error", "Error de autenticación");
                error.put("message", "Credenciales inválidas");
                return ResponseEntity.status(401).body(error);
            }

            // 6. Generar tokens
            String token = jwtTokenProvider.generateToken(usuario);
            String refreshToken = jwtTokenProvider.generateRefreshToken(usuario);

            log.info("✅ Token generado para: {}", usuario.getUsername());
            log.info("✅ Refresh token generado");

            // 7. Actualizar refresh token en BD
            userService.actualizarRefreshToken(usuario.getUsername(), refreshToken);

            // 8. Construir respuesta
            LoginResponse loginResponse = LoginResponse.builder()
                    .token(token)
                    .refreshToken(refreshToken)
                    .username(usuario.getUsername())
                    .email(usuario.getEmail())
                    .rol(usuario.getRole().name())
                    .build();

            log.info("✅ Login exitoso para: {}", usuario.getUsername());
            log.info("========================================");

            return ResponseEntity.ok(loginResponse);

        } catch (Exception e) {
            log.error("❌ Error inesperado en login: ", e);
            Map<String, String> error = new HashMap<>();
            error.put("error", "Error interno del servidor");
            error.put("message", "Ocurrió un error al procesar el login");
            return ResponseEntity.status(500).body(error);
        }
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        log.info("🔄 Refrescando token");

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
        String token = authHeader.substring(7);
        String username = jwtTokenProvider.getUsernameFromToken(token);

        log.info("🔐 Actualizando perfil para usuario: {}", username);

        return ResponseEntity.ok(userService.actualizarPerfilPorUsername(username, actualizarUsuarioDTO));
    }

    @GetMapping("/perfil/{username}")
    public ResponseEntity<UsuarioPerfilDTO> obtenerPerfil(@PathVariable String username) {
        log.info("📋 Obteniendo perfil para: {}", username);
        UsuarioPerfilDTO perfil = userService.obtenerPerfilPorUsername(username);
        return ResponseEntity.ok(perfil);
    }

    @GetMapping("/test-auth")
    public ResponseEntity<?> testAuth(@AuthenticationPrincipal UserDetails userDetails) {
        log.info("🔐 Test de autenticación - Usuario: {}", userDetails != null ? userDetails.getUsername() : "none");
        return ResponseEntity.ok(Map.of(
                "authenticated", userDetails != null,
                "username", userDetails != null ? userDetails.getUsername() : "none",
                "message", "Autenticación funcionando correctamente"
        ));
    }
}