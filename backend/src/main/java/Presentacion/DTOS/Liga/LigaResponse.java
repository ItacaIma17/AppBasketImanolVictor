package Presentacion.DTOS.Liga;

import lombok.Data;
import java.util.List;

@Data
public class LigaResponse {
    private Long id;
    private String nombreLiga;
    private int totalEquipos;
    private List<String> equipos;
}