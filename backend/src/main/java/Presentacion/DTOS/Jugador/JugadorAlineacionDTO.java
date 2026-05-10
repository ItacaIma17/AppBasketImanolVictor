package Presentacion.DTOS.Jugador;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class JugadorAlineacionDTO {

    private Long jugadorId;

    private String nombre;

    private String apellido;

    private Integer dorsal;

    private String posicion;

    private Boolean esTitular;

    public static JugadorAlineacionDTO fromJugador(Long jugadorId, String nombre, String apellido, Integer dorsal, String posicion) {
        return JugadorAlineacionDTO.builder()
                .jugadorId(jugadorId)
                .nombre(nombre)
                .apellido(apellido)
                .dorsal(dorsal)
                .posicion(posicion)
                .build();
    }

    public Long getJugadorId() {
        return jugadorId;
    }

    public String getNombreCompleto() {
        return nombre + " " + (apellido != null ? apellido : "");
    }
}
