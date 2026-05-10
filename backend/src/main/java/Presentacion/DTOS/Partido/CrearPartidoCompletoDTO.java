package Presentacion.DTOS.Partido;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CrearPartidoCompletoDTO {

    private Long equipoLocalId;
    private Long equipoVisitanteId;
    private LocalDateTime fechaIda;
    private String pabellonIda;
    private String ubicacionIda;
    private Integer jornadaIda;
    private Long ligaId;

    private Long arbitroId;

    private boolean crearVuelta;
    private LocalDateTime fechaVuelta;
    private String pabellonVuelta;
    private String ubicacionVuelta;
    private Integer jornadaVuelta;
    private Integer diferenciaJornadas;
}
