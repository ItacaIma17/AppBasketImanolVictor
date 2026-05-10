package Presentacion.DTOS.Entrenador;

import lombok.Data;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
public class CrearEntrenadorDTO {
    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    private String apellido;

    @NotBlank(message = "El username es obligatorio")
    private String username;

    @Email(message = "Email inválido")
    @NotBlank(message = "El email es obligatorio")
    private String email;

    @NotBlank(message = "La contraseña es obligatoria")
    private String password;

    @NotNull(message = "La edad es obligatoria")
    private int edad;

    @NotBlank(message = "El código de entrenador es obligatorio")
    private String codigoEntrenador;

    private String telefono;
    private String experiencia;
}
