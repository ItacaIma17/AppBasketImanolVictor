package Presentacion.Controllers;


import Aplicacion.Services.ActaService;
import Presentacion.DTOS.Arbitro.ActaRequestDTO;
import Presentacion.DTOS.Arbitro.ActaResponseDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/actas")
@RequiredArgsConstructor
public class ActaController {

    private final ActaService actaService;

    @PostMapping("/guardar")
    public ResponseEntity<ActaResponseDTO> guardarActa(
            @RequestBody ActaRequestDTO request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(actaService.guardarActa(request, userDetails.getUsername()));
    }

    @GetMapping("/partido/{partidoId}")
    public ResponseEntity<ActaResponseDTO> obtenerActa(@PathVariable Long partidoId) {
        return ResponseEntity.ok(actaService.obtenerActa(partidoId));
    }
}
