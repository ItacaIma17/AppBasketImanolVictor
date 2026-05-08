package Presentacion.DTOS.Admin;

import lombok.Data;
import java.util.List;

@Data
public class ComunicadoAdminDTO {
    private String asunto;
    private String email;
    private String mensaje;
    private List<String> destinatarios; // emails específicos
    private String rolDestino;          // TODOS, JUGADOR, ENTRENADOR, ARBITRO
}