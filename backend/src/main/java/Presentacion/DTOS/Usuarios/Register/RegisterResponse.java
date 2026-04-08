package Presentacion.DTOS.Usuarios.Register;



import lombok.Data;

@Data
public class RegisterResponse{
    private String username;
    private String email;
    private boolean verificado;
}
