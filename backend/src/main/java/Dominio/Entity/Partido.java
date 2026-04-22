package Dominio.Entity;

import Dominio.Entity.EstadoPartido.EstadoPartido;
import jakarta.persistence.*;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "partidos")
@Data
public class Partido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipo_local_id", nullable = false)
    private Equipo equipoLocal;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipo_visitante_id", nullable = false)
    private Equipo equipoVisitante;

    @Column(name = "fecha", nullable = false)
    private LocalDate fecha;

    @Column(name = "hora", nullable = false)
    private LocalTime hora;

    @Column(name = "pabellon", nullable = false, length = 100)
    private String pabellon;

    @Column(name = "direccion_pabellon", length = 255)
    private String direccionPabellon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "liga_id", nullable = false)
    private Liga liga;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "arbitro_id")
    private Arbitro arbitro;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado", nullable = false)
    private EstadoPartido estado = EstadoPartido.PROGRAMADO;

    @Column(name = "marcador_local")
    private Integer marcadorLocal;

    @Column(name = "marcador_visitante")
    private Integer marcadorVisitante;

    @Column(name = "acta_url", length = 500)
    private String actaUrl;

    @Column(name = "observaciones", columnDefinition = "TEXT")
    private String observaciones;

    @CreationTimestamp
    @Column(name = "fecha_creacion", updatable = false)
    private LocalDateTime fechaCreacion;

    @UpdateTimestamp
    @Column(name = "fecha_actualizacion")
    private LocalDateTime fechaActualizacion;

    // Método auxiliar para obtener el nombre del rival
    public String getNombreRival(Equipo equipoReferencia) {
        if (equipoLocal.equals(equipoReferencia)) {
            return equipoVisitante.getNombre();
        } else if (equipoVisitante.equals(equipoReferencia)) {
            return equipoLocal.getNombre();
        }
        return "Desconocido";
    }

    // Método para verificar si un equipo participa en el partido
    public boolean participaEquipo(Equipo equipo) {
        return equipoLocal.equals(equipo) || equipoVisitante.equals(equipo);
    }

    // Método para obtener todos los jugadores de ambos equipos
    public List<Jugador> obtenerTodosLosJugadores() {
        List<Jugador> todosJugadores = new ArrayList<>();
        if (equipoLocal != null && equipoLocal.getJugadores() != null) {
            todosJugadores.addAll(equipoLocal.getJugadores());
        }
        if (equipoVisitante != null && equipoVisitante.getJugadores() != null) {
            todosJugadores.addAll(equipoVisitante.getJugadores());
        }
        return todosJugadores;
    }

    // Método para obtener el entrenador del equipo que participa
    public Entrenador getEntrenadorByEquipo(Equipo equipo) {
        if (equipoLocal.equals(equipo)) {
            return equipoLocal.getEntrenador();
        } else if (equipoVisitante.equals(equipo)) {
            return equipoVisitante.getEntrenador();
        }
        return null;
    }
}