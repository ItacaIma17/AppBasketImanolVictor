package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "jugadores_alineacion")
@Data
public class JugadorAlineacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "alineacion_id", nullable = false)
    private Alineacion alineacion;

    @ManyToOne
    @JoinColumn(name = "jugador_id", nullable = false)
    private Jugador jugador;

    @Column(nullable = false)
    private boolean titular;

    private int dorsal;

    private String posicion;
}
