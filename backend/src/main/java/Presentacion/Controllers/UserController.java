package Presentacion.Controllers;

import Aplicacion.Services.UserService;
import Dominio.Entity.Usuario;
import Dominio.Repositorys.UserRepository;
import Presentacion.DTOS.Equipo.SeguirEquipoDTO;
import Presentacion.DTOS.Jugador.JugadorResponse;
import Presentacion.DTOS.Jugador.SeguirReponseDTO;
import Presentacion.DTOS.Usuarios.ChangePasswordDTO;
import Presentacion.DTOS.Usuarios.ChangePasswordResponseDTO;
import Presentacion.DTOS.Usuarios.Login.LoginRequest;
import Presentacion.DTOS.Usuarios.Login.LoginResponse;
import Presentacion.DTOS.Usuarios.Login.VerificacionEmailDTO;
import Presentacion.DTOS.Usuarios.Register.RegisterResponse;
import Presentacion.DTOS.Usuarios.Register.RegistroBaseDTO;
import Presentacion.DTOS.Usuarios.UsuarioPerfilDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final UserRepository usuarioRepository;

    @PostMapping("/registro")
    public ResponseEntity<RegisterResponse> registro(@RequestBody RegistroBaseDTO dto) {
        userService.registrarInicial(dto);
            RegisterResponse register = new RegisterResponse();
            register.setUsername(dto.getUsername());
            register.setEmail(dto.getEmail());
            register.setVerificado(true);
            return ResponseEntity.ok(register);
    }

    @PostMapping("/verificar")
    public ResponseEntity<LoginResponse> verificarCodigo(@RequestBody VerificacionEmailDTO dto) {
        return ResponseEntity.ok(userService.verificarCodigo(dto));
    }

    @PostMapping("/reenviar-codigo")
    public ResponseEntity<Void> reenviarCodigo(@RequestParam String email) {
        userService.reenviarCodigo(email);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest dto) {
        return ResponseEntity.ok(userService.login(dto));
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<LoginResponse> refreshToken(@RequestParam String refreshToken) {
        return ResponseEntity.ok(userService.refreshToken(refreshToken));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestParam String username) {
        userService.logout(username);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/perfil/{username}")
    public ResponseEntity<UsuarioPerfilDTO> obtenerPerfil(@PathVariable String username) {
        return ResponseEntity.ok(userService.obtenerPerfil(username));
    }

    @PutMapping("/cambiar-password")
    public ResponseEntity<ChangePasswordResponseDTO> cambiarPassword(
            @RequestBody ChangePasswordDTO changePasswordDTO) {
        userService.cambiarPassword(changePasswordDTO);
        ChangePasswordResponseDTO responseDTO = new ChangePasswordResponseDTO();
        responseDTO.setEmail(changePasswordDTO.getEmail());
        responseDTO.setFechaActualizacion(LocalDateTime.now());
        return ResponseEntity.ok(responseDTO);
    }

    @PostMapping("/seguirJugador/{idJugador}")
    public ResponseEntity<SeguirReponseDTO> seguirJugador(
            @PathVariable Long idJugador,
            @AuthenticationPrincipal UserDetails userDetails) {
        Usuario usuario = usuarioRepository.findByUsername(userDetails.getUsername());
        return ResponseEntity.ok(userService.seguirJugador(idJugador, usuario));
    }

    @PostMapping("/seguirEquipo/{idEquipo}")
    public ResponseEntity<SeguirEquipoDTO> seguirEquipo(
            @PathVariable Long idEquipo,
            @AuthenticationPrincipal UserDetails userDetails) {
        Usuario usuario = usuarioRepository.findByUsername(userDetails.getUsername());
        return ResponseEntity.ok(userService.seguirEquipo(idEquipo, usuario));
    }

}