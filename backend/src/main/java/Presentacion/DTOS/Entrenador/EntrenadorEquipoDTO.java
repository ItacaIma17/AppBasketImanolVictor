package Presentacion.DTOS.Entrenador;

import lombok.Data;

@Data
public class EntrenadorEquipoDTO {
    private Long entrenadorId;
    private String nombreEntrenador;
    private String apellido;
    private String email;
    private String username;
    private Long equipoId;
    private String nombreEquipo;
    private String nombreLiga;
    private String nombreEstadio;
    private boolean tieneEquipo;
}
