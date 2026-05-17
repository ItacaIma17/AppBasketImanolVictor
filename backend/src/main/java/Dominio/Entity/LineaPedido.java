package Dominio.Entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "lineas_pedido")
@Data
public class LineaPedido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pedido_id", nullable = false)
    private Pedido pedido;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "producto_id", nullable = false)
    private Producto producto;

    private int cantidad;
    private double precioUnitario;
    private String nombreProducto;
}
