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
import org.slf4j.Logger;


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

        return Jwts.builder()
                .subject(username)
                .claim("rol", role)
                .claim("email", email)
                .claim("authorities", List.of("ROLE_" + role))
                .issuedAt(now)
                .expiration(expiry)
                .signWith(getSigningKey())
                .compact();
    }

    public List<SimpleGrantedAuthority> getAuthorities(String token) {
        try {
            Claims claims = extractClaims(token);
            List<String> authorities = claims.get("authorities", List.class);
            if (authorities != null) {
                return authorities.stream()
                        .map(SimpleGrantedAuthority::new)
                        .collect(Collectors.toList());
            }
        } catch (Exception e) {
            log.warn("No se pudieron extraer autoridades del token", e);
        }
        return Collections.emptyList();
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
        Date expiry = new Date(now.getTime() + 604800000);

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
    // PARSEO
    // ─────────────────────────────

    public Claims extractClaims(String token) {
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
            return null;
        }
    }

    public String getRoleFromToken(String token) {
        try {
            return extractClaims(token).get("rol", String.class);
        } catch (Exception e) {
            return null;
        }
    }

    // ─────────────────────────────
    // VALIDACIÓN (IMPORTANTE)
    // ─────────────────────────────

    public boolean validateToken(String token) {
        try {
            extractClaims(token);
            return true;
        } catch (Exception e) {
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