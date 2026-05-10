package Presentacion.DTOS.Jugador;

import lombok.Data;

@Data
public class SeguirReponseDTO {

    private String nombreJugador;
    private String nombreEquipoJugador;
    private String posicion;

    public SeguirReponseDTO(){}

    public SeguirReponseDTO(String nombreJugador, String nombreEquipoJugador, String posicion) {
        this.nombreJugador = nombreJugador;
        this.nombreEquipoJugador = nombreEquipoJugador;
        this.posicion = posicion;
    }
}

