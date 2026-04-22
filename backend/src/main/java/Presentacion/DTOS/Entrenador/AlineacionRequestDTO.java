package Presentacion.DTOS.Entrenador;

import lombok.Data;

import java.util.List;

@Data
public class AlineacionRequestDTO {
    private Long partidoId;
    private List<Long> titulares;
    private List<Long> suplentes;
}
