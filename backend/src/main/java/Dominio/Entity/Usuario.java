package Dominio.Entity;

import Dominio.Entity.Roles.Roles;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "usuarios")
@Data
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(unique = true, nullable = false)
    private String username;

    private String nombre;
    private String apellido;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    private Roles role;

    private int edad;
    private boolean verificado;
    private boolean bloqueado;

    private String codigoVerificacion;
    private LocalDateTime expiracionCodigo;

    @Column(length = 1000)
    private String token;

    @Column(length = 1000)
    private String refreshToken;

    @OneToOne(mappedBy = "usuario", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Entrenador entrenador;

    @OneToOne(mappedBy = "usuario", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Arbitro arbitro;

    @OneToOne(mappedBy = "usuario", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Jugador jugador;

    @ManyToMany
    @JoinTable(
            name = "usuario_equipos_seguidos",
            joinColumns = @JoinColumn(name = "usuario_id"),
            inverseJoinColumns = @JoinColumn(name = "equipo_id")
    )
    private List<Equipo> listaEquiposSiguiendo = new ArrayList<>();

    @ManyToMany
    @JoinTable(
            name = "usuario_jugadores_seguidos",
            joinColumns = @JoinColumn(name = "usuario_id"),
            inverseJoinColumns = @JoinColumn(name = "jugador_id")
    )
    private List<Jugador> listaJugadorSiguiendo = new ArrayList<>();
}
