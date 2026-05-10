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
    private String nombre;
    private String apellido;
    private int dorsal;
    private String posicion;
    private boolean titular;

    public static JugadorAlineacionRequestDTO fromJugador(Long jugadorId, String nombre, String apellido, int dorsal, String posicion, boolean titular) {
        return JugadorAlineacionRequestDTO.builder()
                .jugadorId(jugadorId)
                .nombre(nombre)
                .apellido(apellido)
                .dorsal(dorsal)
                .posicion(posicion)
                .titular(titular)
                .build();
    }
}
