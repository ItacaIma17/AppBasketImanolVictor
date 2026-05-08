package Presentacion.Config;

import Dominio.Entity.Usuario;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Component
@Slf4j
public class JwtTokenProvider {

    @Value("${jwt.secret:miClaveSecretaParaJWT123456789012345678901234567890}")
    private String jwtSecret;

    @Value("${jwt.expiration:86400000}")
    private long jwtExpiration;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }

    // ─────────────────────────────
    // GENERACIÓN
    // ─────────────────────────────

    public String generateToken(String username, String role, String email) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + jwtExpiration);

        String roleWithPrefix = role.startsWith("ROLE_") ? role : "ROLE_" + role;

        return Jwts.builder()
                .subject(username)
                .claim("role", roleWithPrefix)  // ✅ Cambiado de "rol" a "role"
                .claim("email", email)
                .issuedAt(now)
                .expiration(expiry)
                .signWith(getSigningKey())
                .compact();
    }

    public String generateToken(Usuario usuario) {
        return generateToken(
                usuario.getUsername(),
                usuario.getRole().name(),
                usuario.getEmail()
        );
    }

    public String generateRefreshToken(String username) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + 604800000); // 7 días

        return Jwts.builder()
                .subject(username)
                .issuedAt(now)
                .expiration(expiry)
                .signWith(getSigningKey())
                .compact();
    }

    public String generateRefreshToken(Usuario usuario) {
        return generateRefreshToken(usuario.getUsername());
    }

    // ─────────────────────────────
    // PARSEO - CORREGIDO
    // ─────────────────────────────

    public Claims extractClaims(String token) {
        // ✅ CORREGIDO: usar parser() en lugar de parse()
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public String getUsernameFromToken(String token) {
        try {
            return extractClaims(token).getSubject();
        } catch (Exception e) {
            log.error("Error obteniendo username del token: {}", e.getMessage());
            return null;
        }
    }

    public String getRoleFromToken(String token) {
        try {
            Claims claims = extractClaims(token);
            // ✅ Buscar primero "role", luego "rol"
            String role = claims.get("role", String.class);
            if (role == null) {
                role = claims.get("rol", String.class);
            }
            log.info("📝 Rol extraído del token: {}", role);
            return role;
        } catch (Exception e) {
            log.error("Error obteniendo role del token: {}", e.getMessage());
            return null;
        }
    }

    // ─────────────────────────────
    // VALIDACIÓN
    // ─────────────────────────────

    public boolean validateToken(String token) {
        try {
            extractClaims(token);
            return true;
        } catch (Exception e) {
            log.error("Token inválido: {}", e.getMessage());
            return false;
        }
    }

    public String getTokenFromRequest(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            return header.substring(7);
        }
        return null;
    }
}