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

    private String pabellon;

    private Long arbitroId;
}
