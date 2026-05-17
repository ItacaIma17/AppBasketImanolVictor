package Presentacion.DTOS.Tienda;

import Dominio.Entity.LineaPedido;
import Dominio.Entity.Pedido;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
public class PedidoResponse {
    private Long id;
    private String estado;
    private double total;
    private LocalDateTime fechaPedido;
    private List<LineaResponse> lineas;
    private PagoResumen pago;

    @Data
    public static class LineaResponse {
        private Long productoId;
        private String nombreProducto;
        private int cantidad;
        private double precioUnitario;
        private double subtotal;
    }

    @Data
    public static class PagoResumen {
        private String transaccionId;
        private String estado;
        private String ultimosCuatroDigitos;
        private LocalDateTime fechaPago;
    }

    public static PedidoResponse fromEntity(Pedido pedido) {
        PedidoResponse dto = new PedidoResponse();
        dto.setId(pedido.getId());
        dto.setEstado(pedido.getEstado());
        dto.setTotal(pedido.getTotal());
        dto.setFechaPedido(pedido.getFechaPedido());

        dto.setLineas(pedido.getLineas().stream().map(l -> {
            LineaResponse lr = new LineaResponse();
            lr.setProductoId(l.getProducto().getIdProducto());
            lr.setNombreProducto(l.getNombreProducto());
            lr.setCantidad(l.getCantidad());
            lr.setPrecioUnitario(l.getPrecioUnitario());
            lr.setSubtotal(l.getCantidad() * l.getPrecioUnitario());
            return lr;
        }).collect(Collectors.toList()));

        if (pedido.getPago() != null) {
            PagoResumen pr = new PagoResumen();
            pr.setTransaccionId(pedido.getPago().getTransaccionId());
            pr.setEstado(pedido.getPago().getEstado());
            pr.setUltimosCuatroDigitos(pedido.getPago().getUltimosCuatroDigitos());
            pr.setFechaPago(pedido.getPago().getFechaPago());
            dto.setPago(pr);
        }

        return dto;
    }
}
