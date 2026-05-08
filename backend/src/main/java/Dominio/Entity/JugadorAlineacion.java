package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "jugadores_alineacion")
@Data
@NoArgsConstructor
@AllArgsConstructor
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
    private boolean titular = false;

    @Column(nullable = false)
    private int dorsal;

    @Column(nullable = false)
    private String posicion;

    @Column(nullable = false)
    private String nombreJugador;

    private String apellidoJugador;
}