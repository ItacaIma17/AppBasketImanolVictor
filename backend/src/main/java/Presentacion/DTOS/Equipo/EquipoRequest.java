// Presentacion/DTOS/Equipo/EquipoRequest.java
package Presentacion.DTOS.Equipo;

import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import lombok.Data;

@Data
public class EquipoRequest {
    private String nombre;
    private String ciudad;
    private String nombreEstadio;
    private Integer anoFundacion;  // Puede ser null
    private String escudoUrl;
    private Long ligaId;

    public Equipo toEntity() {
        Equipo equipo = new Equipo();
        equipo.setNombre(this.nombre);
        equipo.setCiudad(this.ciudad);
        equipo.setNombreEstadio(this.nombreEstadio);

        if (this.anoFundacion != null) {
            equipo.setAnoFundacion(this.anoFundacion);
        } else {
            equipo.setAnoFundacion(0); // o un valor por defecto
        }

        equipo.setEscudoUrl(this.escudoUrl);

        // Crear liga solo si el ID no es null
        if (this.ligaId != null) {
            Liga liga = new Liga();
            liga.setId(this.ligaId);
            equipo.setLiga(liga);
        }

        return equipo;
    }
}