package Presentacion.DTOS.Usuarios;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ChangePasswordResponseDTO {
    private String email;
    private LocalDateTime fechaActualizacion;
}
