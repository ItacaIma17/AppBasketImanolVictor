package Presentacion.DTOS.Equipo;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
public class CrearEquipoDTO {
    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;

    private String nombreEstadio;

    private String ciudad;

    private int añoFundacion;

    private String escudoUrl;

    @NotNull(message = "La liga es obligatoria")
    private Long ligaId;
}
