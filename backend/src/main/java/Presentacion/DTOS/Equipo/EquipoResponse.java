package Presentacion.DTOS.Equipo;

import lombok.Data;
import java.util.List;

@Data
public class EquipoResponse {
    private Long id;
    private String nombre;
    private String nombreEstadio;
    private String ligaNombre;
    private String entrenadorNombre;
    private int totalJugadores;
    private List<String> jugadores;
}