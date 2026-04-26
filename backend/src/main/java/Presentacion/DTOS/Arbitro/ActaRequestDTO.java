package Presentacion.DTOS.Arbitro;

import lombok.Data;
import java.util.List;

@Data
public class ActaRequestDTO {
    private Long partidoId;
    private String resultadoLocal;
    private String resultadoVisitante;
    private String observaciones;
    private List<EventoRequestDTO> eventos;

    @Data
    public static class EventoRequestDTO {
        private Long jugadorId;
        private String nombreJugador;
        private String nombreEquipo;
        private Integer minuto;
        private String tipo;
        private String descripcion;
    }
}