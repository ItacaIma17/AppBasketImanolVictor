package Presentacion.DTOS.Arbitro;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AsignarArbitroDTO {
    private Long arbitroId;
    private String arbitroCodigo;
    private Long partidoId;
    private String partidoDescripcion; 
}