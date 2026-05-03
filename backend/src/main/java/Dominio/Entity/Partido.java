package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "partidos")
@Data
public class Partido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "liga_id")
    private Liga liga;

    @ManyToOne
    @JoinColumn(name = "equipo_local_id", nullable = false)
    private Equipo equipoLocal;

    @ManyToOne
    @JoinColumn(name = "equipo_visitante_id", nullable = false)
    private Equipo equipoVisitante;

    @ManyToOne
    @JoinColumn(name = "arbitro_id")
    private Arbitro arbitro;

    @Column(nullable = false)
    private LocalDateTime fecha;

    private String ubicacion;  // Esto es direccionPabellon

    private String pabellon;

    private Integer resultadoLocal;  // puntosLocal

    private Integer resultadoVisitante;  // puntosVisitante

    @Column(nullable = false)
    private String estado;  // PROGRAMADO, EN_CURSO, FINALIZADO

    @ManyToOne
    @JoinColumn(name = "acta_partido_id")
    private ActaPartido actaPartido;

    public boolean participaEquipo(Equipo equipo) {
        if (equipo == null) return false;
        return (equipoLocal != null && equipoLocal.getId().equals(equipo.getId())) ||
                (equipoVisitante != null && equipoVisitante.getId().equals(equipo.getId()));
    }

}