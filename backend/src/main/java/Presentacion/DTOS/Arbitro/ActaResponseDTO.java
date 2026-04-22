package Presentacion.DTOS.Arbitro;

import Dominio.Entity.TipoEevento;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Data
public class ActaResponseDTO {
    private Long id;
    private Long partidoId;
    private String equipoLocal;
    private String equipoVisitante;
    private String resultadoLocal;
    private String resultadoVisitante;
    private LocalTime fecha;
    private LocalDate hora;
    private String pabellon;
    private String observaciones;
    private String arbitroNombre;
    private List<EventoResponseDTO> eventos;

    @Data
    public static class EventoResponseDTO {
        private Long id;
        private String jugadorNombre;
        private String equipoNombre;
        private int minuto;
        private TipoEevento tipo;
        private String descripcion;
    }
}
