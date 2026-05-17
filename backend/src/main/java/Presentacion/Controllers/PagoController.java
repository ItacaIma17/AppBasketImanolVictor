package Presentacion.Controllers;

import Aplicacion.Services.PagoService;
import Presentacion.DTOS.Tienda.PagoResponse;
import Presentacion.DTOS.Tienda.ProcesarPagoRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/pagos")
@RequiredArgsConstructor
public class PagoController {

    private final PagoService pagoService;

    /**
     * FAB Pay - Pasarela de pago simulada.
     *
     * Tarjetas de prueba:
     *   APROBADO: cualquier número de 16 dígitos que NO empiece por 0000
     *             Ejemplo: 4111111111111111
     *   RECHAZADO: número que empiece por 0000
     *              Ejemplo: 0000111111111111
     */
    @PostMapping("/procesar")
    public ResponseEntity<PagoResponse> procesarPago(
            @RequestBody ProcesarPagoRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(pagoService.procesarPago(request, userDetails.getUsername()));
    }
}
