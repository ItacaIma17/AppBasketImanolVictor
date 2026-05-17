package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "Productos")
@Data
public class Producto {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idProducto;

    private String nombreProducto;

    @Column(length = 1000)
    private String descripcion;

    private int stock;
    private double precio;
    private String categoria;

    @Column(columnDefinition = "TEXT")
    private String imagenUrl;

    private boolean activo = true;
}
