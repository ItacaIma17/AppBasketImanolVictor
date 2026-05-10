package Presentacion.DTOS.Producto;

import lombok.Data;

@Data
public class ProductoRequest {
    private String nombreProducto;
    private int stock;
    private double precio;

    public ProductoRequest(){}

    public ProductoRequest(String nombreProducto, int stock, double precio) {
        this.nombreProducto = nombreProducto;
        this.stock = stock;
        this.precio = precio;
    }
}

