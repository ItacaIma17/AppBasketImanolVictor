package Presentacion.Controllers;

import Aplicacion.Services.AlineacionService;
import Presentacion.DTOS.Alineacion.AlineacionesParaPartidoDTO;
import Presentacion.DTOS.Entrenador.AlineacionRequestDTO;
import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import Presentacion.DTOS.Partido.AlineacionParaActaDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/alineaciones")
@RequiredArgsConstructor
public class AlineacionController {

    private final AlineacionService alineacionService;

    @PostMapping("/presentar")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<AlineacionResponseDTO> presentarAlineacion(
            @RequestBody AlineacionRequestDTO request,
            @AuthenticationPrincipal UserDetails userDetails) {

        log.info("Entrenador {} presentando alineación para partido {}",
                userDetails.getUsername(), request.getPartidoId());

        return ResponseEntity.ok(alineacionService.presentarAlineacion(request, userDetails.getUsername()));
    }

    @GetMapping("/partido/{partidoId}/equipo/{equipoId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AlineacionResponseDTO> getAlineacionByPartidoAndEquipo(
            @PathVariable Long partidoId,
            @PathVariable Long equipoId) {

        return ResponseEntity.ok(alineacionService.getAlineacion(partidoId, equipoId));
    }

    @GetMapping("/partido/{partidoId}")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN')")
    public ResponseEntity<AlineacionesParaPartidoDTO> getAlineacionesPartido(@PathVariable Long partidoId) {
        return ResponseEntity.ok(alineacionService.getAlineacionesPartido(partidoId));
    }

    @GetMapping("/partido/{partidoId}/acta")
    @PreAuthorize("hasAnyRole('ARBITRO', 'ADMIN')")
    public ResponseEntity<AlineacionParaActaDTO> getAlineacionesParaActa(@PathVariable Long partidoId) {
        return ResponseEntity.ok(alineacionService.getAlineacionesParaActa(partidoId));
    }

    @PutMapping("/{id}/confirmar")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<AlineacionResponseDTO> confirmarAlineacion(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {

        return ResponseEntity.ok(alineacionService.confirmarAlineacion(id, userDetails.getUsername()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ENTRENADOR')")
    public ResponseEntity<AlineacionResponseDTO> actualizarAlineacion(
            @PathVariable Long id,
            @RequestBody AlineacionRequestDTO request,
            @AuthenticationPrincipal UserDetails userDetails) {

        return ResponseEntity.ok(alineacionService.actualizarAlineacion(id, request, userDetails.getUsername()));
    }
}