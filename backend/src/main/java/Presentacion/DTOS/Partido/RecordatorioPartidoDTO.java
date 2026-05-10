package Presentacion.DTOS.Partido;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class RecordatorioPartidoDTO {

    private String sendto;
    private String nombreUsuario;
    private String nombreRival;
    private LocalDateTime fecha;
    private String pabellon;
    private String direccionPabellon;

    public RecordatorioPartidoDTO() {
    }

    public RecordatorioPartidoDTO(String direccionPabellon, String sendto, String nombreUsuario,String nombreRival,
                                  LocalDateTime fecha,
                                  String pabellon) {
        this.direccionPabellon = direccionPabellon;
        this.sendto = sendto;
        this.nombreUsuario = nombreUsuario;
        this.fecha = fecha;
        this.pabellon = pabellon;
    }
}

