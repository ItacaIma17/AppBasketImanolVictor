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

    @Column(nullable = false)
    private String nombre;

    private String apellido;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(unique = true, nullable = false)
    private String email;

    private int edad;
    private double altura;
    private double peso;
    private String posicion;
    private int dorsal;

    @Column(unique = true, nullable = false)
    private String codigoJugador;

    @Enumerated(EnumType.STRING)
    private Roles role;

    private boolean verificado;

    @ManyToOne
    @JoinColumn(name = "equipo_id")
    private Equipo equipo;
}