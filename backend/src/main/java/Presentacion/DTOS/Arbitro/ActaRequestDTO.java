package Presentacion.DTOS.Arbitro;

import lombok.Data;
import java.util.List;

@Data
public class ActaRequestDTO {
    private Long partidoId;
    private String resultadoLocal;
    private String resultadoVisitante;
    private String observaciones;
    private List<EventoDTO> eventos;

    @Data
    public static class EventoDTO {
        private Long jugadorId;
        private String nombreJugador;
        private String nombreEquipo;
        private int minuto;
        private String tipo;
        private String descripcion;
    }
}
