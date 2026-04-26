package Presentacion.Controllers;

import Aplicacion.Services.AdminService;
import Dominio.Entity.Roles.Roles;
import Dominio.Entity.Usuario;
import Dominio.Repositorys.UserRepository;
import Presentacion.Config.JwtTokenProvider;
import Presentacion.DTOS.Admin.AdminPanelInfoDTO;
import Presentacion.DTOS.Admin.ComunicadoAdminDTO;
import Presentacion.DTOS.Admin.SancionDTO;
import Presentacion.DTOS.Arbitro.ArbitroRequest;
import Presentacion.DTOS.Arbitro.AsignarArbitroDTO;
import Presentacion.DTOS.Jugador.JugadorResponse;
import Presentacion.DTOS.Usuarios.UsuarioPerfilDTO;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    // ── PANEL RESUMEN ─────────────────────────────────────

    @GetMapping("/panel")
    public ResponseEntity<AdminPanelInfoDTO> panel(
            HttpServletRequest request) {
        requireAdmin(request);
        return ResponseEntity.ok(adminService.obtenerResumen());
    }

    // ── USUARIOS ──────────────────────────────────────────

    @GetMapping("/usuarios")
    public ResponseEntity<List<UsuarioPerfilDTO>> listarUsuarios(
            HttpServletRequest request) {
        requireAdmin(request);
        return ResponseEntity.ok(adminService.listarTodosUsuarios());
    }

    @GetMapping("/usuarios/rol/{rol}")
    public ResponseEntity<List<UsuarioPerfilDTO>> listarPorRol(
            @PathVariable String rol,
            HttpServletRequest request) {
        requireAdmin(request);
        return ResponseEntity.ok(adminService.listarUsuariosPorRol(
                Roles.valueOf(rol.toUpperCase())));
    }

    @GetMapping("/usuarios/pendientes")
    public ResponseEntity<List<UsuarioPerfilDTO>> pendientes(
            HttpServletRequest request) {
        requireAdmin(request);
        return ResponseEntity.ok(adminService.listarUsuariosPendientes());
    }

    @GetMapping("/usuarios/bloqueados")
    public ResponseEntity<List<UsuarioPerfilDTO>> bloqueados(
            HttpServletRequest request) {
        requireAdmin(request);
        return ResponseEntity.ok(adminService.listarUsuariosBloqueados());
    }

    @PutMapping("/usuarios/{id}/bloquear")
    public ResponseEntity<Void> bloquear(
            @PathVariable Long id,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.bloquearUsuario(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/usuarios/{id}/desbloquear")
    public ResponseEntity<Void> desbloquear(
            @PathVariable Long id,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.desbloquearUsuario(id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/usuarios/{id}")
    public ResponseEntity<Void> eliminarUsuario(
            @PathVariable Long id,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.eliminarUsuario(id);
        return ResponseEntity.noContent().build();
    }

    // ── JUGADORES ─────────────────────────────────────────

    @GetMapping("/jugadores/sin-equipo")
    public ResponseEntity<List<JugadorResponse>> sinEquipo(
            HttpServletRequest request) {
        requireAdmin(request);
        return ResponseEntity.ok(adminService.listarJugadoresSinEquipo());
    }

    @PutMapping("/jugadores/{jugadorId}/equipo/{equipoId}")
    public ResponseEntity<Void> asignarJugador(
            @PathVariable Long jugadorId,
            @PathVariable Long equipoId,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.asignarJugadorAEquipo(jugadorId, equipoId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/equipos/{equipoId}/jugadores")
    public ResponseEntity<Void> asignarMasivo(
            @PathVariable Long equipoId,
            @RequestBody List<Long> jugadorIds,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.asignarJugadoresMasivo(equipoId, jugadorIds);
        return ResponseEntity.ok().build();
    }

    // ── ENTRENADORES ──────────────────────────────────────

    @PutMapping("/entrenadores/{entrenadorId}/equipo/{equipoId}")
    public ResponseEntity<Void> asignarEntrenador(
            @PathVariable Long entrenadorId,
            @PathVariable Long equipoId,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.asignarEntrenadorAEquipo(entrenadorId, equipoId);
        return ResponseEntity.ok().build();
    }

    // ── ÁRBITROS ──────────────────────────────────────────

    @PutMapping("/arbitros/{arbitroId}/partido/{partidoId}")
    public ResponseEntity<Void> asignarArbitro(
            @RequestBody AsignarArbitroDTO asignarArbitro,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.asignarArbitroAPartido( asignarArbitro);
        return ResponseEntity.ok().build();
    }

    // ── SANCIONES ─────────────────────────────────────────

    @PostMapping("/sanciones")
    public ResponseEntity<Void> sancionar(
            @RequestBody SancionDTO dto,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.sancionarJugador(dto);
        return ResponseEntity.ok().build();
    }

    // ── COMUNICADOS ───────────────────────────────────────

    @PostMapping("/comunicados")
    public ResponseEntity<Void> comunicado(
            @RequestBody ComunicadoAdminDTO dto,
            HttpServletRequest request) {
        requireAdmin(request);
        adminService.enviarComunicado(dto);
        return ResponseEntity.ok().build();
    }

    // ── PRIVADO ───────────────────────────────────────────

    private void requireAdmin(HttpServletRequest request) {
        String token = jwtTokenProvider.getTokenFromRequest(request);
        if (token == null)
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,
                    "Token no proporcionado");
        String username = jwtTokenProvider.getUsernameFromToken(token);
        Usuario usuario = userRepository.findByUsername(username);
        if (usuario == null || usuario.getRole() != Roles.ADMIN)
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Solo el administrador puede realizar esta acción");
    }
}