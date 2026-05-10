package Presentacion.DTOS.Alineacion;

import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AlineacionesPartidoDTO {
    private Long partidoId;
    private String equipoLocal;
    private String equipoVisitante;
    private AlineacionResponseDTO alineacionLocal;
    private AlineacionResponseDTO alineacionVisitante;
    private boolean ambasPresentadas;
    private boolean alineacionLocalConfirmada;
    private boolean alineacionVisitanteConfirmada;
    private boolean partidoListoParaComenzar;

    public static AlineacionesPartidoDTO fromEntities(
            AlineacionResponseDTO local,
            AlineacionResponseDTO visitante,
            Long partidoId,
            String nombreLocal,
            String nombreVisitante) {

        boolean localPresente = local != null;
        boolean visitantePresente = visitante != null;
        boolean ambasPresentadas = localPresente && visitantePresente;
        boolean localConfirmada = localPresente && local.isConfirmada();
        boolean visitanteConfirmada = visitantePresente && visitante.isConfirmada();

        return AlineacionesPartidoDTO.builder()
                .partidoId(partidoId)
                .equipoLocal(nombreLocal)
                .equipoVisitante(nombreVisitante)
                .alineacionLocal(local)
                .alineacionVisitante(visitante)
                .ambasPresentadas(ambasPresentadas)
                .alineacionLocalConfirmada(localConfirmada)
                .alineacionVisitanteConfirmada(visitanteConfirmada)
                .partidoListoParaComenzar(localConfirmada && visitanteConfirmada)
                .build();
    }
}
