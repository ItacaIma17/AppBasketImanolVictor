@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EquipoResponse {

    private Long id;
    private Long ligaId;
    private String nombre;
    private String ciudad;
    private String nombreEstadio;
    private Integer anoFundacion;
    private String escudoUrl;

    private String nombreLiga;

    private Long entrenadorId;
    private String nombreEntrenador;
    private Boolean tieneEntrenador;

    private String codigoSolicitud;
    private Boolean solicitudPendiente;

    private Integer numeroJugadores;

    private Integer puntosFavor;
    private Integer puntosContra;
    private Integer victorias;
    private Integer derrotas;

    public static EquipoResponse fromEntity(Equipo equipo) {
        return EquipoResponse.builder()
                .id(equipo.getId())
                .ligaId(equipo.getLiga() != null ? equipo.getLiga().getId() : null)
                .nombre(equipo.getNombre())
                .ciudad(equipo.getCiudad())
                .nombreEstadio(equipo.getNombreEstadio())
                .anoFundacion(equipo.getAnoFundacion())
                .escudoUrl(equipo.getEscudoUrl())

                .nombreLiga(equipo.getLiga() != null ? equipo.getLiga().getNombreLiga() : "Sin liga")

                .entrenadorId(equipo.getEntrenador() != null ? equipo.getEntrenador().getId() : null)
                .nombreEntrenador(equipo.getEntrenador() != null ?
                        equipo.getEntrenador().getNombre() + " " + equipo.getEntrenador().getApellido()
                        : "Sin entrenador")
                .tieneEntrenador(equipo.getEntrenador() != null)

                .codigoSolicitud(equipo.getCodigoSolicitud())
                .solicitudPendiente(Boolean.TRUE.equals(equipo.getSolicitudPendiente()))

                .numeroJugadores(equipo.getJugadores() != null ? equipo.getJugadores().size() : 0)

                .puntosFavor(equipo.getPuntosFavor())
                .puntosContra(equipo.getPuntosContra())
                .victorias(equipo.getVictorias())
                .derrotas(equipo.getDerrotas())

                .build();
    }
}
