package Presentacion.DTOS.Producto;

import lombok.Data;

@Data
public class ProductoRequest {
    private String nombreProducto;
    private String descripcion;
    private int stock;
    private double precio;
    private String categoria;
    private String imagenUrl;
}

