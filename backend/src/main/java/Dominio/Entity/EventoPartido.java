package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "eventos_partido")
@Data
public class EventoPartido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "acta_id", nullable = false)
    private ActaPartido acta;

    @ManyToOne
    @JoinColumn(name = "jugador_id")
    private Jugador jugador;

    private String nombreJugador;

    private String nombreEquipo;

    @Column(nullable = false)
    private int minuto;

    @Enumerated(EnumType.STRING)
    private TipoEevento tipo;

    private String descripcion;
}


