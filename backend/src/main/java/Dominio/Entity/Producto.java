package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "Productos")
@Data
public class Producto {

    @Id
    @GeneratedValue
    private int idProducto;

    private String nombreProducto;
    private int stock;
    private double precio;
}