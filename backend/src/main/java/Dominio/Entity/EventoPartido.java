package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

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

    @Column(nullable = false)
    private String nombreJugador;

    @Column(nullable = false)
    private String nombreEquipo;

    @Column(nullable = false)
    private Integer minuto;

    @Column(nullable = false)
    private String tipo;

    private String descripcion;

    private Integer puntos;

    private LocalDateTime timestamp;
}