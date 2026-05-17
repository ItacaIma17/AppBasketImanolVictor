package Presentacion.DTOS.Tienda;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class PagoResponse {
    private String transaccionId;
    private String estado;           // APROBADO / RECHAZADO
    private String mensaje;
    private double importe;
    private String ultimosCuatroDigitos;
    private LocalDateTime fechaPago;
    private Long pedidoId;
}
