package Presentacion.DTOS.Arbitro;

import Dominio.Entity.Arbitro;
import Dominio.Entity.EstadoPartido.EstadoPartido;
import lombok.Builder;
import lombok.Data;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
public class ArbitroResponse {
    private Long id;
    private String username;
    private String email;
    private String nombre;
    private String apellidos;
    private Integer edad;
    private String codigoArbitro;
    private Boolean verificado;
    private Boolean activo;
    private Integer partidosAsignados;
    private List<PartidoAsignadoDTO> proximosPartidos;

    @Data
    @Builder
    public static class PartidoAsignadoDTO {
        private Long partidoId;
        private String equipoLocal;
        private String equipoVisitante;
        private String fecha;
        private String hora;
        private String ubicacion;
    }

    public static ArbitroResponse fromEntity(Arbitro arbitro) {
        if (arbitro == null) {
            return null;
        }

        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

        ArbitroResponseBuilder builder = ArbitroResponse.builder()
                .id(arbitro.getId())
                .username(arbitro.getUsername())
                .email(arbitro.getEmail())
                .nombre(arbitro.getNombre())
                .apellidos(arbitro.getApellidos())
                .edad(arbitro.getEdad())
                .codigoArbitro(arbitro.getCodigoArbitro())
                .verificado(arbitro.getVerificado())
                .activo(arbitro.getActivo() != null ? arbitro.getActivo() : true);

        if (arbitro.getPartidos() != null && !arbitro.getPartidos().isEmpty()) {
            builder.partidosAsignados(arbitro.getPartidos().size())
                    .proximosPartidos(arbitro.getPartidos().stream()
                            .filter(p -> !EstadoPartido.FINALIZADO.name().equals(p.getEstado()))
                            .map(p -> PartidoAsignadoDTO.builder()
                                    .partidoId(p.getId())
                                    .equipoLocal(p.getEquipoLocal().getNombre())
                                    .equipoVisitante(p.getEquipoVisitante().getNombre())
                                    .fecha(p.getFecha().format(dateFormatter))
                                    .hora(p.getFecha().format(timeFormatter))
                                    .ubicacion(p.getUbicacion() != null ? p.getUbicacion() : p.getPabellon())
                                    .build())
                            .collect(Collectors.toList()));
        } else {
            builder.partidosAsignados(0)
                    .proximosPartidos(List.of());
        }

        return builder.build();
    }
}
