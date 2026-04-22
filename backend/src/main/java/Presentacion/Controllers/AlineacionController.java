package Presentacion.Controllers;

import Aplicacion.Services.AlineacionService;
import Presentacion.DTOS.Entrenador.AlineacionRequestDTO;
import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/alineaciones")
@RequiredArgsConstructor
public class AlineacionController {

    private final AlineacionService alineacionService;

    @PostMapping("/guardar")
    public ResponseEntity<AlineacionResponseDTO> guardarAlineacion(
            @RequestBody AlineacionRequestDTO request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(alineacionService.guardarAlineacion(request, userDetails.getUsername()));
    }

    @GetMapping("/partido/{partidoId}")
    public ResponseEntity<AlineacionResponseDTO> obtenerAlineacion(
            @PathVariable Long partidoId,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(alineacionService.obtenerAlineacion(partidoId, userDetails.getUsername()));
    }
}
