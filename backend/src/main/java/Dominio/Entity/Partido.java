package Dominio.Entity;

import Presentacion.DTOS.Entrenador.AlineacionResponseDTO;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "partidos")
@Data
public class Partido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
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

    private String ubicacion;

    private String pabellon;

    private Integer resultadoLocal;

    private Integer resultadoVisitante;

    @Column(nullable = false)
    private String estado;

    private Integer jornada;

    @OneToOne(mappedBy = "partido", cascade = CascadeType.ALL)
    private ActaPartido acta;

    @OneToOne(mappedBy = "partido", cascade = CascadeType.ALL)
    private Alineacion alineacionLocal;

    @OneToOne(mappedBy = "partido", cascade = CascadeType.ALL)
    private Alineacion alineacionVisitante;

    public boolean participaEquipo(Equipo equipo) {
        if (equipo == null) return false;
        return (equipoLocal != null && equipoLocal.getId().equals(equipo.getId())) ||
                (equipoVisitante != null && equipoVisitante.getId().equals(equipo.getId()));
    }
}