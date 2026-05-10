package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Entity
@Table(name = "alineaciones")
@Data
public class Alineacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "partido_id", nullable = false)
    private Partido partido;

    @ManyToOne
    @JoinColumn(name = "equipo_id", nullable = false)
    private Equipo equipo;

    @ManyToOne
    @JoinColumn(name = "entrenador_id")
    private Entrenador entrenador;

    @Column(nullable = false)
    private LocalDateTime fechaPresentacion;

    @Column(nullable = false)
    private boolean confirmada = false;

    @Column(name = "bloqueada")
    private boolean bloqueada = true;

    @OneToMany(mappedBy = "alineacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<JugadorAlineacion> jugadores = new ArrayList<>();

    public void addJugador(JugadorAlineacion jugador) {
        jugadores.add(jugador);
        jugador.setAlineacion(this);
    }

    public void removeJugador(JugadorAlineacion jugador) {
        jugadores.remove(jugador);
        jugador.setAlineacion(null);
    }

    public List<JugadorAlineacion> getTitulares() {
        return jugadores.stream()
                .filter(JugadorAlineacion::isTitular)
                .collect(Collectors.toList());
    }

    public List<JugadorAlineacion> getSuplentes() {
        return jugadores.stream()
                .filter(j -> !j.isTitular())
                .collect(Collectors.toList());
    }
}
