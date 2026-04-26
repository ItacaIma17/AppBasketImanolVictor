package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Year;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "ligas")
@Data
public class Liga {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String nombreLiga;

    private int numeroEquipos;

    @OneToMany(mappedBy = "liga", cascade = CascadeType.ALL)
    private List<Equipo> equipos = new ArrayList<>();
}