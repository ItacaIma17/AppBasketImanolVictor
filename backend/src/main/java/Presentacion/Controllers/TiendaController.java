package Presentacion.Controllers;

import Aplicacion.Services.TiendaService;
import Presentacion.DTOS.Tienda.CrearPedidoRequest;
import Presentacion.DTOS.Tienda.PedidoResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tienda")
@RequiredArgsConstructor
public class TiendaController {

    private final TiendaService tiendaService;

    @PostMapping("/pedido")
    public ResponseEntity<PedidoResponse> crearPedido(
            @RequestBody CrearPedidoRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(tiendaService.crearPedido(request, userDetails.getUsername()));
    }

    @GetMapping("/mis-pedidos")
    public ResponseEntity<List<PedidoResponse>> misPedidos(
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(tiendaService.misPedidos(userDetails.getUsername()));
    }

    @GetMapping("/pedido/{id}")
    public ResponseEntity<PedidoResponse> obtenerPedido(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(tiendaService.obtenerPedido(id, userDetails.getUsername()));
    }

    @PutMapping("/pedido/{id}/cancelar")
    public ResponseEntity<PedidoResponse> cancelarPedido(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(tiendaService.cancelarPedido(id, userDetails.getUsername()));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/pedido/{id}/estado")
    public ResponseEntity<PedidoResponse> actualizarEstado(
            @PathVariable Long id,
            @RequestParam String estado) {
        return ResponseEntity.ok(tiendaService.actualizarEstadoPedido(id, estado));
    }
}
