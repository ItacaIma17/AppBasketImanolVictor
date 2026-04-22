package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "actas_partido")
@Data
public class ActaPartido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "partido_id", nullable = false)
    private Partido partido;

    @ManyToOne
    @JoinColumn(name = "arbitro_id", nullable = false)
    private Arbitro arbitro;

    @Column(nullable = false)
    private LocalDateTime fechaActa;

    private String observaciones;

    private String resultadoLocal;

    private String resultadoVisitante;

    @OneToMany(mappedBy = "acta", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EventoPartido> eventos = new ArrayList<>();
}
