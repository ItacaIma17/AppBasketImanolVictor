package Presentacion.DTOS.Tienda;

import lombok.Data;

import java.util.List;

@Data
public class CrearPedidoRequest {
    private List<ItemPedidoDTO> items;

    @Data
    public static class ItemPedidoDTO {
        private Long productoId;
        private int cantidad;
    }
}
