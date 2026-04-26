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
public class LigaRequest {
    private String nombreLiga;
    private String pais;
    private Integer numeroEquipos;

    public Liga toEntity() {
        Liga liga = new Liga();
        liga.setNombreLiga(this.nombreLiga);
        liga.setNumeroEquipos(this.numeroEquipos);
        return liga;
    }
}