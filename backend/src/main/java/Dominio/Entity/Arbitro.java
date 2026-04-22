package Dominio.Entity;

import Dominio.Entity.Roles.Roles;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "arbitros")
@Data
public class Arbitro {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private String apellidos;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(unique = true, nullable = false)
    private String email;

    private int edad;

    @Column(unique = true, nullable = false)
    private String codigoArbitro;

    @Enumerated(EnumType.STRING)
    private Roles role;

    private boolean verificado;

    @OneToOne
    @JoinColumn(name = "usuario_id", unique = true)
    private Usuario usuario;
}