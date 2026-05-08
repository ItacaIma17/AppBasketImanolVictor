package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "ligas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Liga {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String nombreLiga;

    private String pais;

    private Integer numeroEquipos;

    private String temporada;

    @OneToMany(mappedBy = "liga", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Equipo> equipos = new ArrayList<>();

    // Método helper para obtener número de equipos registrados
    public int getNumeroEquiposRegistrados() {
        return equipos != null ? equipos.size() : 0;
    }
}