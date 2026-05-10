package Presentacion.Controllers;

import Aplicacion.Services.EntrenadorService;
import Aplicacion.Services.EquipoService;
import Dominio.Entity.Entrenador;
import Dominio.Repositorys.EntrenadorRepository;
import Presentacion.Config.JwtTokenProvider;
import Presentacion.DTOS.Entrenador.AsignarEquipoDTO;
import Presentacion.DTOS.Entrenador.EntrenadorEquipoDTO;
import Presentacion.DTOS.Entrenador.EntrenadorRequest;
import Presentacion.DTOS.Entrenador.CrearEntrenadorDTO;
import Presentacion.DTOS.Jugador.JugadorResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/entrenadores")
@RequiredArgsConstructor
public class EntrenadorController {

    private final EntrenadorService entrenadorService;
    private final JwtTokenProvider jwtTokenProvider;
    private final EntrenadorRepository entrenadorRepository;
    private final EquipoService equipoService;

    @GetMapping("/mi-equipo")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<EntrenadorEquipoDTO> obtenerMiEquipo(HttpServletRequest request) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            log.error("No hay usuario autenticado en el contexto");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String username = authentication.getName();
        log.info("Obteniendo equipo del entrenador: {}", username);

        try {
            EntrenadorEquipoDTO equipo = entrenadorService.obtenerMiEquipo(username);
            return ResponseEntity.ok(equipo);
        } catch (Exception e) {
            if (e.getMessage().contains("no tiene un equipo asignado")) {
                log.info("Entrenador {} no tiene equipo asignado", username);
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
            log.error("Error obteniendo equipo: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/mi-equipo-v2")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<EntrenadorEquipoDTO> obtenerMiEquipoV2(HttpServletRequest request) {

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.error(" No hay token de autenticación");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String token = authHeader.substring(7);
        String username = jwtTokenProvider.getUsernameFromToken(token);

        if (username == null) {
            log.error(" No se pudo extraer username del token");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        log.info(" Obteniendo equipo del entrenador (v2): {}", username);

        try {
            EntrenadorEquipoDTO equipo = entrenadorService.obtenerMiEquipo(username);
            return ResponseEntity.ok(equipo);
        } catch (Exception e) {
            if (e.getMessage().contains("no tiene un equipo asignado")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
            }
            throw e;
        }
    }

    @PostMapping("/generar-codigo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> generarCodigo() {
        String codigo = entrenadorService.generarCodigoEntrenador();
        return ResponseEntity.ok(java.util.Map.of("codigo", codigo));
    }

    @PostMapping("/crear")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EntrenadorRequest> crearEntrenador(@Valid @RequestBody CrearEntrenadorDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(entrenadorService.crearEntrenador(dto));
    }

    @PostMapping("/asignar-equipo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EntrenadorEquipoDTO> asignarEquipo(
            @RequestBody AsignarEquipoDTO dto,
            HttpServletRequest request) {

        String authHeader = request.getHeader("Authorization");
        String token = authHeader.substring(7);
        String adminUsername = jwtTokenProvider.getUsernameFromToken(token);

        log.info("Admin {} asignando equipo {} a entrenador {}",
                adminUsername, dto.getEquipoId(), dto.getCodigoEntrenador());

        return ResponseEntity.ok(entrenadorService.asignarEquipoAEntrenador(dto, adminUsername));
    }

    @GetMapping("/listar")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EntrenadorRequest>> listarTodosEntrenadores() {
        return ResponseEntity.ok(entrenadorService.listarTodosEntrenadores());
    }

    @GetMapping("/sin-equipo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EntrenadorRequest>> listarEntrenadoresSinEquipo() {
        return ResponseEntity.ok(entrenadorService.listarEntrenadoresSinEquipo());
    }

    @GetMapping("/con-equipo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EntrenadorRequest>> listarEntrenadoresConEquipo() {
        return ResponseEntity.ok(entrenadorService.listarEntrenadoresConEquipo());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EntrenadorRequest> obtenerEntrenadorPorId(@PathVariable Long id) {
        return ResponseEntity.ok(entrenadorService.obtenerEntrenadorPorId(id));
    }

    @GetMapping("/username/{username}")
    public ResponseEntity<EntrenadorRequest> obtenerEntrenadorPorUsername(@PathVariable String username) {
        return ResponseEntity.ok(entrenadorService.obtenerEntrenadorPorUsername(username));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> eliminarEntrenador(@PathVariable Long id) {
        entrenadorService.eliminarEntrenador(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/mis-jugadores")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<List<JugadorResponse>> getMisJugadores(
            HttpServletRequest request) {

        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            log.error(" No hay token de autenticación");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String token = authHeader.substring(7);
        String username = jwtTokenProvider.getUsernameFromToken(token);

        if (username == null) {
            log.error(" No se pudo extraer username del token");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        log.info(" Obteniendo jugadores del entrenador: {}", username);

        Entrenador entrenador = entrenadorRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "Entrenador no encontrado: " + username));

        if (entrenador.getEquipo() == null) {
            log.warn(" Entrenador {} no tiene equipo asignado", username);
            return ResponseEntity.ok(List.of());
        }

        Long equipoId = entrenador.getEquipo().getId();
        log.info(" Entrenador {} tiene equipo ID: {}", username, equipoId);

        List<JugadorResponse> jugadores = equipoService.getJugadoresByEquipoId(equipoId);
        log.info(" Se encontraron {} jugadores", jugadores.size());

        return ResponseEntity.ok(jugadores);
    }
}
