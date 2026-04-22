// Dominio/Entity/Entrenador.java
package Dominio.Entity;

import Dominio.Entity.Roles.Roles;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "entrenadores")
@Data
public class Entrenador {

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

    @Column(unique = true, nullable = false)
    private String codigoEntrenador;

    @Enumerated(EnumType.STRING)
    private Roles role;

    private boolean verificado;

    private String telefono;

    private String experiencia;

    @OneToOne
    @JoinColumn(name = "usuario_id", unique = true)
    private Usuario usuario;

    @OneToOne(mappedBy = "entrenador")
    private Equipo equipo;

    // Constructor vacío
    public Entrenador() {}

    // Método para obtener nombre completo
    public String getNombreCompleto() {
        return nombre + " " + (apellido != null ? apellido : "");
    }
}