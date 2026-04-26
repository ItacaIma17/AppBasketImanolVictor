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
    private Integer numeroEquipos;
    private Integer numeroEquiposRegistrados;

    public static LigaResponse fromEntity(Liga liga) {
        return LigaResponse.builder()
                .id(liga.getId())
                .nombreLiga(liga.getNombreLiga())
                .numeroEquipos(liga.getNumeroEquipos())
                .numeroEquiposRegistrados(liga.getEquipos() != null ? liga.getEquipos().size() : 0)
                .build();
    }
}