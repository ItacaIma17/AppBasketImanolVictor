package Presentacion.DTOS.Jugador;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class JugadorRequest {
    private String nombre;
    private String apellido;
    private String username;
    private String email;
    private String password;
    private Integer edad;
    private Double altura;
    private Double peso;
    private String posicion;
    private Integer dorsal;
    private String codigoJugador;
    private Long equipoId;

    private String role;
}
