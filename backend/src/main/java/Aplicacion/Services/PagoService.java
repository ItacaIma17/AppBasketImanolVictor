package Aplicacion.Services;

import Dominio.Entity.PagoSimulado;
import Dominio.Entity.Pedido;
import Dominio.Repositorys.PagoSimuladoRepository;
import Dominio.Repositorys.PedidoRepository;
import Presentacion.DTOS.Tienda.PagoResponse;
import Presentacion.DTOS.Tienda.ProcesarPagoRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class PagoService {

    private final PedidoRepository pedidoRepository;
    private final PagoSimuladoRepository pagoSimuladoRepository;
    private final TiendaService tiendaService;
    private final EmailService emailService;

    @Transactional
    public PagoResponse procesarPago(ProcesarPagoRequest request, String username) {
        Pedido pedido = pedidoRepository.findById(request.getPedidoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Pedido no encontrado"));

        if (!pedido.getUsuario().getUsername().equals(username)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No tienes acceso a este pedido");
        }

        if ("PAGADO".equals(pedido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Este pedido ya ha sido pagado");
        }

        if ("CANCELADO".equals(pedido.getEstado())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No se puede pagar un pedido cancelado");
        }

        String rechazo = validarTarjeta(request);
        String transaccionId = UUID.randomUUID().toString();
        LocalDateTime ahora = LocalDateTime.now();
        boolean aprobado = rechazo == null;
        String ultimosCuatro = aprobado
                ? request.getNumeroTarjeta().substring(request.getNumeroTarjeta().length() - 4)
                : "????";

        PagoSimulado pago = new PagoSimulado();
        pago.setPedido(pedido);
        pago.setTransaccionId(transaccionId);
        pago.setUltimosCuatroDigitos(ultimosCuatro);
        pago.setNombreTitular(request.getNombreTitular());
        pago.setImporte(pedido.getTotal());
        pago.setEstado(aprobado ? "APROBADO" : "RECHAZADO");
        pago.setMensaje(aprobado ? "Pago procesado correctamente por FAB Pay" : rechazo);
        pago.setFechaPago(ahora);

        if (aprobado) {
            tiendaService.marcarComoPagado(pedido);
            pagoSimuladoRepository.save(pago);
            log.info("FAB Pay: pago APROBADO - Transacción {} - Pedido {} - {}€",
                    transaccionId, pedido.getId(), pedido.getTotal());
            try {
                String email = pedido.getUsuario().getEmail();
                String nombre = pedido.getUsuario().getNombre();
                List<String> lineas = pedido.getLineas().stream()
                        .map(l -> l.getNombreProducto() + " ×" + l.getCantidad()
                                  + " — " + String.format("%.2f €", l.getPrecioUnitario() * l.getCantidad()))
                        .collect(Collectors.toList());
                emailService.enviarConfirmacionPedido(email, nombre, pedido.getId(), pedido.getTotal(), lineas);
            } catch (Exception ex) {
                log.warn("No se pudo enviar email de confirmación para pedido {}: {}", pedido.getId(), ex.getMessage());
            }
        } else {
            pagoSimuladoRepository.save(pago);
            log.warn("FAB Pay: pago RECHAZADO - Pedido {} - Motivo: {}", pedido.getId(), rechazo);
        }

        return PagoResponse.builder()
                .transaccionId(transaccionId)
                .estado(pago.getEstado())
                .mensaje(pago.getMensaje())
                .importe(pedido.getTotal())
                .ultimosCuatroDigitos(ultimosCuatro)
                .fechaPago(ahora)
                .pedidoId(pedido.getId())
                .build();
    }

    private String validarTarjeta(ProcesarPagoRequest r) {
        if (r.getNumeroTarjeta() == null || !r.getNumeroTarjeta().matches("\\d{16}")) {
            return "Número de tarjeta inválido. Debe contener exactamente 16 dígitos";
        }
        if (r.getCvv() == null || !r.getCvv().matches("\\d{3}")) {
            return "CVV inválido. Debe contener exactamente 3 dígitos";
        }
        if (r.getNombreTitular() == null || r.getNombreTitular().isBlank()) {
            return "El nombre del titular es obligatorio";
        }
        if (r.getMesExpiracion() < 1 || r.getMesExpiracion() > 12) {
            return "Mes de expiración inválido";
        }
        LocalDate hoy = LocalDate.now();
        LocalDate expiracion = LocalDate.of(r.getAnioExpiracion(), r.getMesExpiracion(), 1)
                .withDayOfMonth(LocalDate.of(r.getAnioExpiracion(), r.getMesExpiracion(), 1).lengthOfMonth());
        if (expiracion.isBefore(hoy)) {
            return "Tarjeta caducada";
        }
        // Tarjetas test: si empieza por 0000 → rechazada (para pruebas de rechazo)
        if (r.getNumeroTarjeta().startsWith("0000")) {
            return "Tarjeta denegada por el emisor";
        }
        return null;
    }
}
