package Presentacion.DTOS.Usuarios;

import lombok.Data;

@Data
public class ChangePasswordDTO {
    private String email;
    private String password;
    private String newPassword;
}
