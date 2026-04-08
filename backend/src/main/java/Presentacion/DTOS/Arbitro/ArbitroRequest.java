package Presentacion.DTOS.Arbitro;

import lombok.Data;

@Data
public class ArbitroRequest {

    private String nombre;

    private String apellidos;

    private String username;

    private String codigoArbitro;

    private String email;

    private String password;


    public ArbitroRequest() {
    }

    public ArbitroRequest(String nombre, String codigoArbitro, String username, String apellidos) {
        this.nombre = nombre;
        this.codigoArbitro = codigoArbitro;
        this.username = username;
        this.apellidos = apellidos;
    }
}
