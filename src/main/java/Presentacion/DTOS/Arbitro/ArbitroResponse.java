package Presentacion.DTOS.Arbitro;

import lombok.Data;

@Data
public class ArbitroResponse {

    private String nombre;

    private String apellidos;

    private String email;

    private String username;

    public ArbitroResponse(){}

    public ArbitroResponse(String nombre, String apellidos, String username) {
        this.nombre = nombre;
        this.apellidos = apellidos;
        this.username = username;
    }
}
