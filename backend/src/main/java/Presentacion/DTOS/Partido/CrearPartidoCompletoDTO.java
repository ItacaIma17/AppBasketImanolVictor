// Presentacion/DTOS/Partido/CrearPartidoCompletoDTO.java
package Presentacion.DTOS.Partido;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CrearPartidoCompletoDTO {
    // Partido de ida
    private Long equipoLocalId;
    private Long equipoVisitanteId;
    private LocalDateTime fechaIda;
    private String pabellonIda;
    private String ubicacionIda;
    private Integer jornadaIda;
    private Long ligaId;

    // Árbitro (opcional)
    private Long arbitroId;

    // Opcional: partido de vuelta
    private boolean crearVuelta;
    private LocalDateTime fechaVuelta;
    private String pabellonVuelta;
    private String ubicacionVuelta;
    private Integer jornadaVuelta;
    private Integer diferenciaJornadas; // Si se quiere automático
}