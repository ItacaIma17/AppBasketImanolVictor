package Presentacion.DTOS.Admin;

import lombok.Data;

@Data
public class SancionDTO {
    private Long jugadorId;
    private int partidosSancion;
    private String motivo;
}
