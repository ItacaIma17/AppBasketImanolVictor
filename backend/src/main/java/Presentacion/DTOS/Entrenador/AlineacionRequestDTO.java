package Presentacion.DTOS.Entrenador;

import Presentacion.DTOS.Jugador.JugadorAlineacionRequestDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AlineacionRequestDTO {

    private Long partidoId;
    private Long equipoId;

    @Builder.Default
    private List<JugadorAlineacionRequestDTO> titulares = List.of();

    @Builder.Default
    private List<JugadorAlineacionRequestDTO> suplentes = List.of();

    private boolean confirmada;

    /**
     * Valida que la alineación tenga exactamente 5 titulares
     */
    public boolean isValid() {
        return titulares != null && titulares.size() == 5;
    }

    /**
     * Obtiene todos los jugadores de la alineación (titulares + suplentes)
     */
    public List<JugadorAlineacionRequestDTO> getAllJugadores() {
        List<JugadorAlineacionRequestDTO> all = new ArrayList<>();
        if (titulares != null) all.addAll(titulares);
        if (suplentes != null) all.addAll(suplentes);
        return all;
    }
}