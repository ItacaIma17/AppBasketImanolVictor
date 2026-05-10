package Presentacion.DTOS.Liga;

import Dominio.Entity.Liga;
import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LigaResponse {
    private Long id;
    private String nombreLiga;
    private String pais;
    private Integer numeroEquipos;
    private String temporada;
    private Integer numeroEquiposRegistrados;

    public static LigaResponse fromEntity(Liga liga) {
        if (liga == null) return null;

        return LigaResponse.builder()
                .id(liga.getId())
                .nombreLiga(liga.getNombreLiga())
                .pais(liga.getPais())
                .numeroEquipos(liga.getNumeroEquipos())
                .temporada(liga.getTemporada())
                .numeroEquiposRegistrados(liga.getNumeroEquiposRegistrados())
                .build();
    }
}
