package Presentacion.Config;

import Aplicacion.Services.CustomUserDetailsService;
import Dominio.Entity.Usuario;
import Dominio.Repositorys.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService userDetailsService;
    private final UserRepository userRepository;

    private static final List<String> PUBLIC_ENDPOINTS = Arrays.asList(
            // ── Usuarios ──────────────────────────────────
            "/api/usuarios/registro",
            "/api/usuarios/verificar",
            "/api/usuarios/reenviar-codigo",
            "/api/usuarios/login",
            "/api/usuarios/refresh",

            // ── Creación sin token ─────────────────────────
            "/api/entrenadores/crear",
            "/api/arbitros/crear",
            "/api/jugadores/crear"
    );

    public JwtAuthenticationFilter(JwtTokenProvider jwtTokenProvider,
                                   CustomUserDetailsService userDetailsService,
                                   UserRepository userRepository) {
        this.jwtTokenProvider = jwtTokenProvider;
        this.userDetailsService = userDetailsService;
        this.userRepository = userRepository;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return PUBLIC_ENDPOINTS.stream().anyMatch(path::startsWith);
    }


    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String requestURI = request.getRequestURI();
        System.out.println("Procesando filtro JWT para endpoint protegido: " + requestURI);

        String token = jwtTokenProvider.getTokenFromRequest(request);

        if (token == null || token.trim().isEmpty()) {
            System.out.println("No hay token en la petición - continuando sin autenticación");
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String username = jwtTokenProvider.getUsernameFromToken(token);

            if (username == null || username.isEmpty()) {
                System.out.println("No se pudo extraer username del token");
                filterChain.doFilter(request, response);
                return;
            }

            System.out.println("Username extraído del token: " + username);

            Usuario usuario = userRepository.findByUsername(username);

            if (usuario == null) {
                System.out.println("Usuario no encontrado: " + username);
                filterChain.doFilter(request, response);
                return;
            }

            // Validar el token (ahora no requiere comparar con usuario.getToken())
            if (jwtTokenProvider.validateToken(token)) {
                System.out.println("Token válido para usuario: " + username);
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                UsernamePasswordAuthenticationToken authToken =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            } else {
                System.out.println("Token inválido para usuario: " + username);
            }
        } catch (Exception e) {
            System.out.println("Error procesando token: " + e.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}