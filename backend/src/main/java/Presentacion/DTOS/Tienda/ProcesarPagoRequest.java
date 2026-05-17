package Presentacion.DTOS.Tienda;

import lombok.Data;

@Data
public class ProcesarPagoRequest {
    private Long pedidoId;
    private String numeroTarjeta;   // 16 dígitos
    private String nombreTitular;
    private int mesExpiracion;      // 1-12
    private int anioExpiracion;     // ej: 2027
    private String cvv;             // 3 dígitos
}
