package Presentacion.DTOS.Usuarios.Login;

import lombok.Data;

@Data
public class VerificacionEmailDTO {
    private String codigo;
    private String email;

    public VerificacionEmailDTO(){}

    public VerificacionEmailDTO(String codigo, String email) {
        this.codigo = codigo;
        this.email = email;
    }
}
