package Dominio.Entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "equipos")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Equipo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nombre;

    @OneToOne
    @JoinColumn(name = "entrenador_id", unique = true)
    private Entrenador entrenador;

    @ManyToOne
    @JoinColumn(name = "liga_id")
    private Liga liga;

    private String nombreEstadio;

    private String ciudad;

    @Column(name = "año_fundacion")
    private int anoFundacion;

    @Column(columnDefinition = "TEXT")
    private String escudoUrl;

    @OneToMany(mappedBy = "equipo", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Jugador> jugadores = new ArrayList<>();

    @Column(name = "codigo_solicitud")
    private String codigoSolicitud;

    @Column(name = "solicitud_pendiente")
    private Boolean solicitudPendiente = false;

    @Column(name = "entrenador_solicitante_id")
    private Long entrenadorSolicitanteId;

    @Column(name = "victorias")
    private Integer victorias = 0;

    @Column(name = "derrotas")
    private Integer derrotas = 0;

    @Column(name = "puntos_favor")
    private Integer puntosFavor = 0;

    @Column(name = "puntos_contra")
    private Integer puntosContra = 0;
}

