package Presentacion.DTOS.Partido;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PartidoRequestDTO {

    private Long equipoLocalId;

    private Long equipoVisitanteId;

    private LocalDateTime fecha;

    private String ubicacion;

    private Long ligaId;

    private String estado;

    private Integer jornada;

    /** Pabellón en el que se juega el partido. */
    private String pabellon;

    /**
     * ID del árbitro (opcional). Permite asignar / cambiar árbitro al
     * actualizar un partido sin necesidad de un endpoint separado.
     */
    private Long arbitroId;
}