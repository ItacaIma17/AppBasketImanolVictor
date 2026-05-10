package Dominio.Entity;

import Dominio.Entity.Roles.Roles;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "jugadores")
@Data
public class Jugador {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private String apellido;
    private String posicion;
    private double altura;
    private double peso;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(unique = true, nullable = false)
    private String email;

    private int edad;
    private int dorsal;

    @Column(unique = true, nullable = false)
    private String codigoJugador;

    @Enumerated(EnumType.STRING)
    private Roles role;

    private boolean verificado;

    @OneToOne
    @JoinColumn(name = "usuario_id", unique = true)
    private Usuario usuario;

    @ManyToOne
    @JoinColumn(name = "equipo_id")
    private Equipo equipo;

    @Column(nullable = false)
    private int puntosTotales = 0;

    @Column(nullable = false)
    private int rebotesTotales = 0;

    @Column(nullable = false)
    private int asistenciasTotales = 0;

    @Column(nullable = false)
    private int robosTotales = 0;

    @Column(nullable = false)
    private int partidosJugados = 0;
}

