package Presentacion.DTOS.Usuarios.Register;
import lombok.Data;

@Data
public class RegisterRequest {
    private String username;
    private String name;
    private String apellido;
    private String email;
    private String password;
}

