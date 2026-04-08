package Presentacion.DTOS.Usuarios;

import lombok.Data;

@Data
public class UserResponse{
    private int id;
    private String username;
    private String name;
    private String apellido;
    private String email;
    private String role;
    private boolean verificado;

    public UserResponse() {
    }

    public UserResponse(String username, String name, String apellido, String email, String role, boolean verificado) {
        this.username = username;
        this.name = name;
        this.apellido = apellido;
        this.email = email;
        this.role = role;
        this.verificado = verificado;
    }
}
