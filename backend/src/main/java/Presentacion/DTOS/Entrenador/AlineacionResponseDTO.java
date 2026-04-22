package Presentacion.DTOS.Entrenador;

import lombok.Data;

import java.util.List;

@Data
public class AlineacionResponseDTO {
    private Long id;
    private Long partidoId;
    private Long equipoId;
    private String equipoNombre;
    private List<JugadorAlineacionDTO> titulares;
    private List<JugadorAlineacionDTO> suplentes;
    private boolean confirmada;

    @Data
    public static class JugadorAlineacionDTO {
        private Long id;
        private String nombre;
        private String apellido;
        private int dorsal;
        private String posicion;
    }
}
