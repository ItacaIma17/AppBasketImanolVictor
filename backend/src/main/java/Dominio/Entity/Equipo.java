// Dominio/Entity/Equipo.java
package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "equipos")
@Data
public class Equipo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String nombre;

    @OneToOne
    @JoinColumn(name = "equipo", unique = true)
    private Entrenador entrenador;

    @ManyToOne
    @JoinColumn(name = "liga_id")
    private Liga liga;

    private String nombreEstadio;

    private String ciudad;

    private int anoFundacion;

    @Column(columnDefinition = "TEXT")
    private String escudoUrl;

    @OneToMany(mappedBy = "equipo", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Jugador> jugadores = new ArrayList<>();

    @Column(name = "codigo_solicitud")
    private String codigoSolicitud;

    @Column(name = "solicitud_pendiente")
    private Boolean solicitudPendiente = false;

    @Column(name = "entrenador_solicitante_id")
    private Long entrenadorSolicitanteId;


    // Constructor vacío
    public Equipo() {}

    // Constructor con campos básicos
    public Equipo(String nombre, String nombreEstadio, String ciudad) {
        this.nombre = nombre;
        this.nombreEstadio = nombreEstadio;
        this.ciudad = ciudad;
    }
}