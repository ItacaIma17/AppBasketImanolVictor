package Presentacion.DTOS.Jugador;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class JugadorAlineacionRequestDTO {
    private Long jugadorId;
    private int dorsal;
    private String posicion;
    private boolean titular;
}