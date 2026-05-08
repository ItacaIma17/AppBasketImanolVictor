package Dominio.Entity;

import Dominio.Entity.Roles.Roles;
import jakarta.persistence.*;
import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "arbitros")
@Data
public class Arbitro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    private String nombre;
    private String apellidos;
    private Integer edad;
    private String password;

    @Column(unique = true)
    private String codigoArbitro;

    @Enumerated(EnumType.STRING)
    private Roles role;

    private Boolean verificado = false;

    @OneToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    @OneToMany(mappedBy = "arbitro")
    private List<Partido> partidos = new ArrayList<>();

    @OneToMany(mappedBy = "arbitro")
    private List<ActaPartido> actas = new ArrayList<>();
}