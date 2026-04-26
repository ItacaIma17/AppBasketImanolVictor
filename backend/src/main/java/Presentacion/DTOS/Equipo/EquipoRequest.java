// Presentacion/DTOS/Equipo/EquipoRequest.java
package Presentacion.DTOS.Equipo;

import Dominio.Entity.Equipo;
import Dominio.Entity.Liga;
import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EquipoRequest {
    private String nombre;
    private String ciudad;
    private String nombreEstadio;
    private Integer anoFundacion;
    private String escudoUrl;
    private Long ligaId;  // ← Asegurar que existe

    public Equipo toEntity() {
        Equipo equipo = new Equipo();
        equipo.setNombre(this.nombre);
        equipo.setCiudad(this.ciudad);
        equipo.setNombreEstadio(this.nombreEstadio);
        if (this.anoFundacion != null) {
            equipo.setAnoFundacion(this.anoFundacion);
        }
        equipo.setEscudoUrl(this.escudoUrl);

        // No asignar liga aquí, se hace en el servicio
        return equipo;
    }
}