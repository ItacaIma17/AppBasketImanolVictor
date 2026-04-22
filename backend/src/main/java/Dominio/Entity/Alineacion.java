package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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

    @OneToMany(mappedBy = "alineacion", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<JugadorAlineacion> jugadores = new ArrayList<>();
}
