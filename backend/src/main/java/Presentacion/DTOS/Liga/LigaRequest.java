// Presentacion/DTOS/Liga/LigaRequest.java
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
    private String temporada;

    public Liga toEntity() {
        Liga liga = new Liga();
        liga.setNombreLiga(this.nombreLiga);
        liga.setPais(this.pais);
        liga.setNumeroEquipos(this.numeroEquipos != null ? this.numeroEquipos : 0);
        liga.setTemporada(this.temporada);
        return liga;
    }
}