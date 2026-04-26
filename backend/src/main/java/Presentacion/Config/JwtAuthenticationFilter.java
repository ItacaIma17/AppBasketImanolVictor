package Presentacion.Config;

import Presentacion.Config.JwtTokenProvider;
import Aplicacion.Services.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getServletPath();

        // 🔓 ENDPOINTS PÚBLICOS (MUY IMPORTANTE)
        if (isPublicEndpoint(path)) {
            log.info("🔓 Endpoint público: {} {}", request.getMethod(), path);
            filterChain.doFilter(request, response);
            return;
        }

        // 🔍 Obtener header Authorization
        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        try {
            String username = jwtTokenProvider.getUsernameFromToken(token);

            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                if (jwtTokenProvider.validateToken(token)) {
                    // Obtener autoridades directamente del token
                    String role = jwtTokenProvider.getRoleFromToken(token);
                    log.info("🎭 Rol extraído del token: {}", role);

                    // Crear autoridades con prefijo ROLE_
                    List<SimpleGrantedAuthority> authorities = List.of(
                            new SimpleGrantedAuthority("ROLE_" + role)
                    );

                    log.info("🔐 Autoridades asignadas: {}", authorities);

                    // Crear token de autenticación con las autoridades
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(username, null, authorities);

                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    log.info("✅ Autenticación establecida para: {} con rol: {}", username, role);
                }
            }
        } catch (Exception e) {
            log.error("❌ Error procesando token JWT: {}", e.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    // 🔐 Lista centralizada de endpoints públicos
    private boolean isPublicEndpoint(String path) {
        return path.equals("/api/usuarios/login") ||
                path.equals("/api/usuarios/registro") ||
                path.equals("/api/usuarios/verificar") ||
                path.equals("/api/usuarios/reenviar-codigo") ||
                path.equals("/api/usuarios/refresh") ||
                path.equals("/api/ligas/listar") ||
                path.equals("/api/equipos/listar");
    }
}